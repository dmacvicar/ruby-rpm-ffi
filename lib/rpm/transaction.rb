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


  end

end
