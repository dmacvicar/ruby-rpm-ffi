require 'rpm'

module RPM

  class Transaction

    def self.release(ptr)
      RPM::FFI.rpmtsFree(ptr)
    end

    def initialize(opts={})

      opts[:root] ||= '/'

      @ptr = ::FFI::AutoPointer.new(RPM::FFI.rpmtsCreate, Transaction.method(:release))
      RPM::FFI.rpmtsSetRootDir(@ptr, opts[:root])
    end

    # @return [RPM::MatchIterator] Creates an iterator for +tag+ and +val+
    def init_iterator(tag, val)
      raise TypeError if (val && !val.is_a?(String))
      
      it_ptr = RPM::FFI.rpmtsInitIterator(@ptr, tag.nil? ? 0 : tag, val, 0)
      
      raise "Can't init iterator for [#{tag}] -> '#{val}'" if it_ptr.null?
      return MatchIterator.from_ptr(it_ptr)
    end

    # @visibility private
    def ptr
      @ptr
    end
    
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
    def install(pkg, key)
      raise TypeError if not pkg.is_a?(RPM::Package)
      
      @keys ||= Array.new
      raise ArgError, "key must be unique" if @keys.include?(key)
      @keys << key
      
      RPM::FFI.rpmtsAddInstallElement(@ptr, pkg.ptr, key.to_s, 0, nil)
      nil
    end

    # Sets the root directory for this transaction
    # @param [String] root directory
    def root_dir=(dir)
      rc = RPM::FFI.rpmtsSetRootDir(@ptr, dir)
      raise "Can't set #{dir} as root directory" if rc < 0
    end

    # @return [String ] the root directory for this transaction
    def root_dir
      RPM::FFI.rpmtsRootDir(@ptr)
    end

    def flags=(fl)
      RPM::FFI.rpmtsSetFlags(@ptr, fl)
    end

    def flags
      RPM::FFI.rpmtsFlags(@ptr)
    end

    # Performs the transaction.
    # @param [Number] flag Transaction flags, default +RPM::TRANS_FLAG_NONE+
    # @param [Number] filter Transaction filter, default +RPM::PROB_FILTER_NONE+
    # @example
    #   transaction.commit do |sig|
    # end
    # @yield [CallbackData] sig Transaction progress
    def commit
      self.flags = RPM::FFI::TransFlags[:none]

      callback = Proc.new do |h, what, amount, total, key, data|
        puts "#{h} #{what} #{amount} #{total} #{key} #{data}"
      end

      RPM::FFI.rpmtsSetNotifyCallback(@ts, callback, nil)

      rc = RPM::FFI.rpmtsRun(@ptr, nil, :none)

      raise "Transaction Error" if rc < 0
      
      if rc > 0
        ps = RPM::FFI.rpmtsProblems(@ptr)
        psi = RPM::FFI.rpmpsInitIterator(ps)
        while (RPM::FFI.rpmpsNextIterator(psi) >= 0)
          problem = RPM::FFI.rpmpsGetProblem(psi)
          puts RPM::FFI.rpmProblemString.read_string
        end
        RPM::FFI.rpmpsFree(ps)
      end
    end

  end

end
