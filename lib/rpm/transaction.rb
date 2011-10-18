require 'rpm'

module RPM

  class Transaction

    def self.release(ptr)
      RPM::Lib.rpmtsFree(ptr)
    end

    def initialize
      @ts = FFI::AutoPointer.new(RPM::Lib.rpmtsCreate, Transaction.method(:release))
      RPM::Lib.rpmtsSetRootDir(@ts, "/")
    end

    def ptr
      @ts
    end
    
    def each
      it = RPM::Lib.rpmtsInitIterator(@ts, 0, nil, 0)
      #STDERR.puts it.class
      while (not (header = RPM::Lib.rpmdbNextIterator(it)).null?)
        yield Header.new(header)
      end
      RPM::Lib.rpmdbFreeIterator(it)
    end


  end

end
