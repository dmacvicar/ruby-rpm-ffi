require 'rpm/lib'

module RPM

  class Header

    def self.release(ptr)
      RPM::Lib.headerFree(ptr)
    end

    def initialize(hdr=nil)
      if hdr.nil?
        @hdr = FFI::AutoPointer.new(RPM::Lib.headerNew, Header.method(:release))
      elsif hdr.is_a?(FFI::Pointer)
        # ref
        hdr = RPM::Lib.headerLink(hdr)
        @hdr = FFI::AutoPointer.new(hdr, Header.method(:release))
      else
        raise "Can't initialize header with '#{hdr}'"
      end
    end

    def ptr
      @hdr
    end

    def [](tag)
      RPM::Lib.headerGetAsString(@hdr, tag)
    end

    def self.open(filename)
      hdr = FFI::MemoryPointer.new(:pointer)
      fd = nil
      begin
        fd = RPM::Lib.Fopen(filename, 'r')
        puts fd
        RPM.transaction do |ts|
          rc = RPM::Lib.rpmReadPackageFile(ts.ptr, fd, filename, hdr)
        end
      ensure
        RPM::Lib.Fclose(fd) unless fd.nil?
      end
      Header.new(hdr.get_pointer(0))
    end

  end

end
