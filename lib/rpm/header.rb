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

    # @return [String] This package name
    def name
      self[:name]
    end

    # @return [String] This package architecture
    def arch
      self[:arch]
    end

    # TODO signature

    # @return [Version] Version for this package
    def version
      v_ptr = FFI::MemoryPointer.new(:pointer, 1)
      r_ptr = FFI::MemoryPointer.new(:pointer, 1)

      RPM::Lib.headerNVR(ptr, nil, v_ptr, r_ptr)
      v = v_ptr.read_pointer
      r = r_ptr.read_pointer
      "#{v.read_string}-#{r.read_string}"
    end

    def self.open(filename)
      # it sucks not using the std File.open here
      hdr = FFI::MemoryPointer.new(:pointer)
      fd = nil
      begin
        fd = RPM::Lib.Fopen(filename, 'r')
        if RPM::Lib.Ferror(fd) != 0
          raise "#{filename} : #{RPM::Lib.Fstrerror(fd)}"
        end
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
