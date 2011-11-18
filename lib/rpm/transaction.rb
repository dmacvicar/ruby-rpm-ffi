require 'rpm'

module RPM

  class Transaction

    def self.release(ptr)
      RPM::FFI.rpmtsFree(ptr)
    end

    def initialize
      @ts = ::FFI::AutoPointer.new(RPM::FFI.rpmtsCreate, Transaction.method(:release))
      RPM::FFI.rpmtsSetRootDir(@ts, "/")
    end

    def ptr
      @ts
    end
    
    def each
      it = RPM::FFI.rpmtsInitIterator(@ts, 0, nil, 0)
      #STDERR.puts it.class
      while (not (header = RPM::FFI.rpmdbNextIterator(it)).null?)
        yield Header.new(header)
      end
      RPM::FFI.rpmdbFreeIterator(it)
    end

    # Add a install operation to the transaction
    # @param [Package] pkg Package to install
    def install(pkg, key)
      raise TypeError if not pkg.is_a?(RPM::Package)
      
      @keys ||= Array.new
      raise ArgError, "key must be unique" if @keys.include?(key)
      @keys << key
      
      RPM::FFI.rpmtsAddInstallElement(@ts, pkg.ptr, key.to_s, 0, nil)
      nil
    end

    # Sets the root directory for this transaction
    # @param [String] root directory
    def root_dir=(dir)
      rc = RPM::FFI.rpmtsSetRootDir(@ts, dir)
      raise "Can't set #{dir} as root directory" if rc < 0
    end

    # @return [String ] the root directory for this transaction
    def root_dir
      RPM::FFI.rpmtsRootDir(@ts)
    end

    def flags=(fl)
      RPM::FFI.rpmtsSetFlags(@ts, fl)
    end

    def flags
      RPM::FFI.rpmtsFlags(@ts)
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

      rc = RPM::FFI.rpmtsRun(@ts, nil, :none)

      raise "Transaction Error" if rc < 0
      
      if rc > 0
        ps = RPM::FFI.rpmtsProblems(@ts)
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
