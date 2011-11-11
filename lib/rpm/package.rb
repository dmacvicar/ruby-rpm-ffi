require 'rpm/ffi'
require 'rpm/file'

module RPM

  class ChangeLog
    attr_accessor :time, :name, :text
  end

  class Package

    # Create a new package object from data
    # @param [String] str Header data
    # @return [Package]
    def load(data)
      raise NotImplementedError
    end

    def self.create(name, version)
      if not name.is_a?(String)
        raise TypeError, "illegal argument type: name should be String"
      end
      if not version.is_a?(RPM::Version)
        raise TypeError, "illegal argument type: version should be RPM::Version"
      end
      hdr = RPM::FFI.headerNew
      if RPM::FFI.headerPutString(hdr, :name, name) != 1
        raise "Can't set package name: #{name}"
      end
      if RPM::FFI.headerPutString(hdr, :version, ) != 1
        raise "Can't set package version: #{version}"
      end
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

    # Add a int32 value to the package header
    # @param [Number] tag Tag
    # @param [Number] val Value
    def add_int32(tag, val)
      raise NotImplementedError
    end

    # Add a list of strings to the package header
    # @param [Number] tag Tag
    # @param [Array<String>] val Strings to add
    def add_string_array(tag, val)
      raise NotImplementedError
    end

    # Add a binary value to the package header
    # @param [Number] tag Tag
    # @param [String] val String to add
    def add_string(tag, val)
      raise NotImplementedError
    end

    # Add a binary value to the package header
    # @param [Number] tag Tag
    # @param [String] val Value
    def add_binary(tag, val)
      raise NotImplementedError
    end

    # Deletes a tag of the package header
    # @param [Number] tag Tag
    def delete_tag(tag)
      raise NotImplementedError
    end

    # @return a formated string
    # @example
    #   pkg.sprintf("%{name}") => "apache2"
    def sprintf(fmt)
      error = ::FFI::MemoryPointer.new(:pointer, 1)
      val = RPM::FFI.headerFormat(@hdr, fmt, error)
      raise error.get_pointer(0).read_string if val.null?
      val.read_string
    end

    # @return [Number] This package signature
    def signature
      sprintf('%{sigmd5}')
    end

    # @return [Array<RPM::File>] File list for this package
    def files
      basenames = self[:basenames]
      dirnames = self[:dirnames]
      diridxs = self[:dirindexes]
      statelist = self[:filestates]
      flaglist = self[:fileflags]
      sizelist = self[:filesizes]
      modelist = self[:filemodes]
      mtimelist = self[:filemtimes]
      rdevlist = self[:filerdevs]
      linklist = self[:filelinktos]
      md5list = self[:filemd5s]
      ownerlist = self[:fileusername]
      grouplist = self[:filegroupname]

      ret = []
      basenames.each_with_index do |basename, i|
        file = RPM::File.new("#{dirnames[diridxs[i]]}#{basenames[i]}",
                md5list[i],
                linklist.nil? ? nil : linklist[i],
                sizelist[i],
                mtimelist[i],
                ownerlist[i],
                grouplist[i],
                rdevlist[i],
                modelist[i],
                flaglist.nil? ? RPM::FFI::FileAttrs[:none] : flaglist[i],
                statelist.nil? ? RPM::FFI::FileState[:normal] : statelist[i]
        )
        ret << file
      end
      ret
    end

    # @return [Array<RPM::Dependency>] Dependencies for +klass+
    # @example
    #    dependencies(RPM::Provide, :providename, :provideversion, :provideflags)
    #
    # @visibility private
    def dependencies(klass, nametag, versiontag, flagtag)
      deps = []

      nametd = ::FFI::AutoPointer.new(RPM::FFI.rpmtdNew, Package.method(:release_td))
      versiontd = ::FFI::AutoPointer.new(RPM::FFI.rpmtdNew, Package.method(:release_td))
      flagtd = ::FFI::AutoPointer.new(RPM::FFI.rpmtdNew, Package.method(:release_td))

      min = RPM::FFI::HEADERGET_MINMEM
      return deps if (RPM::FFI.headerGet(@hdr, nametag, nametd, min) != 1)
      return deps if (RPM::FFI.headerGet(@hdr, versiontag, versiontd, min) != 1)
      return deps if (RPM::FFI.headerGet(@hdr, flagtag, flagtd, min) != 1)

      RPM::FFI.rpmtdInit(nametd)
      while RPM::FFI.rpmtdNext(nametd) != -1
        deps << klass.new(RPM::FFI.rpmtdGetString(nametd),
                  RPM::Version.new(RPM::FFI.rpmtdNextString(versiontd)),
                  RPM::FFI.rpmtdNextUint32(flagtd), self)
      end
      deps
    end

    # @return [Array<RPM::Provide>] Provides list for this package
    def provides
      dependencies(RPM::Provide, :providename, :provideversion, :provideflags)
    end

    # @return [Array<RPM::Require>] Requires list for this package
    def requires
      dependencies(RPM::Require, :requirename, :requireversion, :requireflags)
    end

    # @return [Array<RPM::Conflicts>] Conflicts list for this package
    def conflicts
      dependencies(RPM::conflicts, :conflictsname, :conflictsversion, :conflictsflags)
    end

    # @return [Array<RPM::Obsolete>] Obsoletes list for this package
    def obsoletes
      dependencies(RPM::Obsoletes, :obsoletename, :obsoleteversion, :obsoleteflags)
    end

    # @return [Array<RPM::Changelog>] changelog of the package as an array 
    def changelog
      entries = []
      nametd = ::FFI::AutoPointer.new(RPM::FFI.rpmtdNew, Package.method(:release_td))
      timetd = ::FFI::AutoPointer.new(RPM::FFI.rpmtdNew, Package.method(:release_td))
      texttd = ::FFI::AutoPointer.new(RPM::FFI.rpmtdNew, Package.method(:release_td))
    
      min = RPM::FFI::HEADERGET_MINMEM
      return deps if (RPM::FFI.headerGet(@hdr, :changelogtime, timetd, min) != 1)
      return deps if (RPM::FFI.headerGet(@hdr, :changelogname, nametd, min) != 1)
      return deps if (RPM::FFI.headerGet(@hdr, :changelogtext, texttd, min) != 1)

      RPM::FFI.rpmtdInit(timetd)
      while RPM::FFI.rpmtdNext(timetd) != -1
        entry = RPM::ChangeLog.new
        entry.time = RPM::FFI.rpmtdGetUint32(timetd)
        entry.name = RPM::FFI.rpmtdNextString(nametd)
        entry.text = RPM::FFI.rpmtdNextString(texttd)
        entries << entry
      end
      entries
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
        when count > 1 then true
        when ret_type == :array_return_type then true
        when type == :string_array_type then true
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

    # String representation of the package: "name-version-release-arch"
    # @return [String]
    def to_s
      return "" if name.nil?
      return name if version.nil?
      return "#{name}-#{version}" if arch.nil?
      return "#{name}-#{version}-#{arch}"
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
      RPM::FFI.rpmtdFree(ptr)
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
