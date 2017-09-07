
module RPM
  CallbackData = Struct.new(:type, :key, :package, :amount, :total) do
    def to_s
      "#{type} #{key} #{package} #{amount} #{total}"
    end
  end

  class Transaction
    def self.release(ptr)
      RPM::C.rpmtsFree(ptr)
    end

    def initialize(opts = {})
      # http://markmail.org/message/ypsiqxop442p7rzz
      # The key pointer needs to stay valid during commit
      # so we keep a reference to them mapping from
      # object_id to ruby object.
      @keys = {}
      opts[:root] ||= '/'

      @ptr = ::FFI::AutoPointer.new(RPM::C.rpmtsCreate, Transaction.method(:release))
      RPM::C.rpmtsSetRootDir(@ptr, opts[:root])
    end

    # @return [RPM::MatchIterator] Creates an iterator for +tag+ and +val+
    def init_iterator(tag, val)
      raise TypeError if val && !val.is_a?(String)

      it_ptr = RPM::C.rpmtsInitIterator(@ptr, tag.nil? ? 0 : tag, val, 0)

      raise "Can't init iterator for [#{tag}] -> '#{val}'" if it_ptr.null?
      MatchIterator.from_ptr(it_ptr)
    end

    # @visibility private
    attr_reader :ptr

    #
    # @yield [Package] Called for each match
    # @param [Number] key RPM tag key
    # @param [String] val Value to match
    # @example
    #   RPM.transaction do |t|
    #     t.each_match(RPM::TAG_ARCH, "x86_64") do |pkg|
    #       puts pkg.name
    #     end
    #   end
    #
    def each_match(key, val, &block)
      it = init_iterator(key, val)

      return it unless block_given?

      it.each(&block)
    end

    #
    # @yield [Package] Called for each package in the database
    # @example
    #   db.each do |pkg|
    #     puts pkg.name
    #   end
    #
    def each(&block)
      each_match(0, nil, &block)
    end

    # Add a install operation to the transaction
    # @param [Package] pkg Package to install
    # @param [String] key e.g. filename where to install from
    def install(pkg, key)
      install_element(pkg, key, upgrade: false)
    end

    # Add an upgrade operation to the transaction
    # @param [Package] pkg Package to upgrade
    # @param [String] key e.g. filename where to install from
    def upgrade(pkg, key)
      install_element(pkg, key, upgrade: true)
    end

    # Add a delete operation to the transaction
    # @param [String, Package, Dependency] pkg Package to delete
    def delete(pkg)
      iterator = case pkg
                 when Package
                   pkg[:sigmd5] ? each_match(:sigmd5, pkg[:sigmd5]) : each_match(:label, pkg[:label])
                 when String
                   each_match(:label, pkg)
                 when Dependency
                   each_match(:label, pkg.name).set_iterator_version(pkg.version)
                 else
                   raise TypeError, 'illegal argument type'
                 end

      iterator.each do |header|
        ret = RPM::C.rpmtsAddEraseElement(@ptr, header.ptr, iterator.offset)
        raise "Error while adding erase/#{pkg} to transaction" if ret != 0
      end
    end

    # Sets the root directory for this transaction
    # @param [String] root directory
    def root_dir=(dir)
      rc = RPM::C.rpmtsSetRootDir(@ptr, dir)
      raise "Can't set #{dir} as root directory" if rc < 0
    end

    # @return [String ] the root directory for this transaction
    def root_dir
      RPM::C.rpmtsRootDir(@ptr)
    end

    def flags=(fl)
      RPM::C.rpmtsSetFlags(@ptr, fl)
    end

    def flags
      RPM::C.rpmtsFlags(@ptr)
    end

    # Determine package order in the transaction according to dependencies
    #
    # The final order ends up as installed packages followed by removed
    # packages, with packages removed for upgrades immediately following
    # the new package to be installed.
    #
    # @returns [Fixnum] no. of (added) packages that could not be ordered
    def order
      RPM::C.rpmtsOrder(@ptr)
    end

    # Free memory needed only for dependency checks and ordering.
    def clean
      RPM::C.rpmtsClean(@ptr)
    end

    def check
      rc = RPM::C.rpmtsCheck(@ptr)
      probs = RPM::C.rpmtsProblems(@ptr)

      return if rc < 0
      begin
        psi = RPM::C.rpmpsInitIterator(probs)
        while RPM::C.rpmpsNextIterator(psi) >= 0
          problem = Problem.from_ptr(RPM::C.rpmpsGetProblem(psi))
          yield problem
        end
      ensure
        RPM::C.rpmpsFree(probs)
      end
    end

    # Performs the transaction.
    # @param [Number] flag Transaction flags, default +RPM::TRANS_FLAG_NONE+
    # @param [Number] filter Transaction filter, default +RPM::PROB_FILTER_NONE+
    # @example
    #   transaction.commit
    # You can supply your own callback
    # @example
    #   transaction.commit do |data|
    #   end
    # end
    # @yield [CallbackData] sig Transaction progress
    def commit
      flags = RPM::C::TransFlags[:none]

      callback = proc do |hdr, type, amount, total, key_ptr, data_ignored|
        key_id = key_ptr.address
        key = @keys.include?(key_id) ? @keys[key_id] : nil

        if block_given?
          package = hdr.null? ? nil : Package.new(hdr)
          data = CallbackData.new(type, key, package, amount, total)
          yield(data)
        else
          RPM::C.rpmShowProgress(hdr, type, amount, total, key, data_ignored)
        end
      end
      # We create a callback to pass to the C method and we
      # call the user supplied callback from there
      #
      # The C callback expects you to return a file handle,
      # We expect from the user to get a File, which we
      # then convert to a file handle to return.
      callback = proc do |hdr, type, amount, total, key_ptr, data_ignored|
        key_id = key_ptr.address
        key = @keys.include?(key_id) ? @keys[key_id] : nil

        if block_given?
          package = hdr.null? ? nil : Package.new(hdr)
          data = CallbackData.new(type, key, package, amount, total)
          ret = yield(data)

          # For OPEN_FILE we need to do some type conversion
          # for certain callback types we need to do some
          case type
          when :inst_open_file
            # For :inst_open_file the user callback has to
            # return the open file
            unless ret.is_a?(::File)
              raise TypeError, "illegal return value type #{ret.class}. Expected File."
            end
            fdt = RPM::C.fdDup(ret.to_i)
            if fdt.null? || RPM::C.Ferror(fdt) != 0
              raise "Can't use opened file #{data.key}: #{RPM::C.Fstrerror(fdt)}"
              RPM::C.Fclose(fdt) unless fdt.nil?
            else
              fdt = RPM::C.fdLink(fdt)
              @fdt = fdt
            end
            # return the (RPM type) file handle
            fdt
          when :inst_close_file
            fdt = @fdt
            RPM::C.Fclose(fdt)
            @fdt = nil
          else
            ret
          end
        else
          # No custom callback given, use the default to show progress
          RPM::C.rpmShowProgress(hdr, type, amount, total, key, data_ignored)
        end
      end

      rc = RPM::C.rpmtsSetNotifyCallback(@ptr, callback, nil)
      raise "Can't set commit callback" if rc != 0

      rc = RPM::C.rpmtsRun(@ptr, nil, :none)

      raise "#{self}: #{RPM::C.rpmlogMessage}" if rc < 0

      if rc > 0
        ps = RPM::C.rpmtsProblems(@ptr)
        psi = RPM::C.rpmpsInitIterator(ps)
        while RPM::C.rpmpsNextIterator(psi) >= 0
          problem = Problem.from_ptr(RPM::C.rpmpsGetProblem(psi))
          STDERR.puts problem
        end
        RPM::C.rpmpsFree(ps)
      end
    end

    # @return [DB] the database associated with this transaction
    def db
      RPM::DB.new(self)
    end

    private

    # @param [Package] pkg package to install
    # @param [String] key e.g. filename where to install from
    # @param opts options
    #   @option :upgrade Upgrade packages if true
    def install_element(pkg, key, opts = {})
      raise TypeError, 'illegal argument type' unless pkg.is_a?(RPM::Package)
      raise ArgumentError, "#{self}: key '#{key}' must be unique" if @keys.include?(key.object_id)

      # keep a reference to the key as rpmtsAddInstallElement will keep a copy
      # of the passed pointer (we pass the object_id)
      @keys[key.object_id] = key

      ret = RPM::C.rpmtsAddInstallElement(@ptr, pkg.ptr, FFI::Pointer.new(key.object_id), opts[:upgrade] ? 1 : 0, nil)
      raise RuntimeError if ret != 0
      nil
    end
  end
end
