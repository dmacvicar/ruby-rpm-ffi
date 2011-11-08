require 'rpm/ffi'

module RPM

  class Package

    # Create a new package object from data
    # @param [String] str Header data
    # @return [Package]
    def load(data)
      raise NotImplementedError
    end

    def self.create(name, version)
      hdr = RPM::FFI.headerNew
      tagc = ::FFI::AutoPointer.new(RPM::FFI.rpmtdNew, Package.method(:release_td))
      RPM::FFI.rpmtdFromString(tagc, RPM::FFI::Tag[:name], name)
      RPM::FFI.headerPut(hdr, tagc, 0)
      Package.new(hdr)
    end

    # Add a dependency to the package header
    # @param [Dependency] dep Dependency to add
    def add_dependency(dep)
      unless dep.is_a?(Dependency)
        raise TypeError.new("illegal argument type: must be a Dependency")
      end

      raise NotImplementedError
    end

  
    # @return [Number] This package signature
    def signature
      error = ::FFI::MemoryPointer.new(:pointer, 1)
      val = RPM::FFI.headerFormat(@hdr, '%{sigmd5}', error)
      raise error.get_pointer(0).read_string if val.null?
      val.read_string
    end

    # Access a header entry
    # @param [Number] tag Tag to return
    # @return [] Value of the entry
    # @example
    #     pkg => #<RPM::Package name="xmlgraphics-fop", version=#<RPM::Version v="1.0", r="22.4">>
    #     pkg[:name] => "xmlgraphics-fop"
    #
    #   or if you have the old ruby-rpm compat loaded
    #
    #     require 'rpm/compat'
    #     pkg[RPM::TAG_NAME] => "xmlgraphics-fop"
    #
    # @return [String, Fixnum, Array<String>, Array<Fixnum>, nil] 
    #   The value of the entry
    def [](tag)
      val = nil
      tagc = ::FFI::AutoPointer.new(RPM::FFI.rpmtdNew, Package.method(:release_td))

      return nil if (RPM::FFI.headerGet(ptr, tag, tagc, 
                      RPM::FFI::HEADERGET_MINMEM) == 0)
      
      type = RPM::FFI.rpmtdType(tagc)
      count = RPM::FFI.rpmtdCount(tagc)
      ret_type = RPM::FFI.rpmTagGetReturnType(tag)

      method_name = case type
        when :int8_type, :char_type, :int16_type, :int32_type, :int64_type then :rpmtdGetNumber
        when :string_type, :string_array_type, :bin_type then :rpmtdGetString
        else raise NotImplementedError, "Don't know how to retrieve type '#{type}'"
      end

      is_array = case
        when count != 1 then true
        when ret_type == :array_return_type then true
        else false
      end

      if is_array
        ret = []
        RPM::FFI.rpmtdInit(tagc)
        while RPM::FFI.rpmtdNext(tagc) != -1
          ret << RPM::FFI.send(method_name, tagc)
        end
        return ret
      end
      
      return RPM::FFI.send(method_name, tagc)
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
      Package.new(hdr.get_pointer(0))
    end

    # @visibility private
    def self.release(ptr)
      RPM::FFI.headerFree(ptr)
    end

    # @visibility private
    def self.release_td(ptr)
      RPM::FFI.rpmTdFree(ptr)
    end

    # @visibility private
    def initialize(hdr=nil)
      if hdr.nil?
        @hdr = ::FFI::AutoPointer.new(RPM::FFI.headerNew, Header.method(:release))
      elsif hdr.is_a?(::FFI::Pointer)
        # ref
        hdr = RPM::FFI.headerLink(hdr)
        @hdr = ::FFI::AutoPointer.new(hdr, Package.method(:release))
      else
        raise "Can't initialize header with '#{hdr}'"
      end
    end

    # @return [RPM::FFI::Header] header pointer
    # @visibility private
    def ptr
      @hdr
    end

  end

end
