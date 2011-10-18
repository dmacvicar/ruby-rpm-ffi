require 'rpm/ffi'

module RPM

  class Header

    def self.release(ptr)
      RPM::FFI.headerFree(ptr)
    end

    def self.release_td(ptr)
      RPM::FFI.rpmTdFree(ptr)
    end

    def initialize(hdr=nil)
      if hdr.nil?
        @hdr = ::FFI::AutoPointer.new(RPM::FFI.headerNew, Header.method(:release))
      elsif hdr.is_a?(::FFI::Pointer)
        # ref
        hdr = RPM::FFI.headerLink(hdr)
        @hdr = ::FFI::AutoPointer.new(hdr, Header.method(:release))
      else
        raise "Can't initialize header with '#{hdr}'"
      end
    end

    def ptr
      @hdr
    end

    def [](tag)

      val = nil
      tagc = ::FFI::AutoPointer.new(RPM::FFI.rpmtdNew, Header.method(:release_td))

      puts ptr
      puts tag
      puts tagc

      return tagval if (RPM::FFI.headerGet(ptr, tag, tagc, 
                    RPM::FFI::HEADERGET_DEFAULT) == 0)
      
      case RPM::FFI.rpmtdType(tagc)
        when TagType[:string_type] then RPM::FFI.rpmtdGetString(tagc)
        else raise NotImplementedError
      end
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
      v_ptr = ::FFI::MemoryPointer.new(:pointer, 1)
      r_ptr = ::FFI::MemoryPointer.new(:pointer, 1)

      RPM::FFI.headerNVR(ptr, nil, v_ptr, r_ptr)
      v = v_ptr.read_pointer
      r = r_ptr.read_pointer
      "#{v.read_string}-#{r.read_string}"
    end

    def self.open(filename)
      # it sucks not using the std File.open here
      hdr = ::FFI::MemoryPointer.new(:pointer)
      fd = nil
      begin
        fd = RPM::FFI.Fopen(filename, 'r')
        if RPM::FFI.Ferror(fd) != 0
          raise "#{filename} : #{RPM::FFI.Fstrerror(fd)}"
        end
        RPM.transaction do |ts|
          rc = RPM::FFI.rpmReadPackageFile(ts.ptr, fd, filename, hdr)
        end
      ensure
        RPM::FFI.Fclose(fd) unless fd.nil?
      end
      Header.new(hdr.get_pointer(0))
    end

  end

end
