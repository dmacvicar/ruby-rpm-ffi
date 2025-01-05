
module RPM
  class ChangeLog
    attr_accessor :time, :name, :text
  end

  class Package
    # Create a new package object from data
    # @param [String] str Header data
    # @return [Package]
    def load(_data)
      raise NotImplementedError
    end

    def self.create(name, version)
      unless name.is_a?(String)
        raise TypeError, 'illegal argument type: name should be String'
      end
      unless version.is_a?(RPM::Version)
        raise TypeError, 'illegal argument type: version should be RPM::Version'
      end
      hdr = RPM::C.headerNew
      if RPM::C.headerPutString(hdr, :name, name) != 1
        raise "Can't set package name: #{name}"
      end
      if RPM::C.headerPutString(hdr, :version, version.v) != 1
        raise "Can't set package version: #{version.v}"
      end
      if version.e
        if RPM::C.headerPutUint32(hdr, :epoch, version.e) != 1
          raise "Can't set package epoch: #{version.e}"
        end
      end
      Package.new(hdr)
    end

    # Add a dependency to the package header
    # @param [Dependency] dep Dependency to add
    def add_dependency(dep)
      unless dep.is_a?(Dependency)
        raise TypeError, 'illegal argument type: must be a Dependency'
      end

      raise NotImplementedError
    end

    # Add a int32 value to the package header
    # @param [Number] tag Tag
    # @param [Number] val Value
    def add_int32(_tag, _val)
      raise NotImplementedError
    end

    # Add a list of strings to the package header
    # @param [Number] tag Tag
    # @param [Array<String>] val Strings to add
    def add_string_array(_tag, _val)
      raise NotImplementedError
    end

    # Add a binary value to the package header
    # @param [Number] tag Tag
    # @param [String] val String to add
    def add_string(_tag, _val)
      raise NotImplementedError
    end

    # Add a binary value to the package header
    # @param [Number] tag Tag
    # @param [String] val Value
    def add_binary(_tag, _val)
      raise NotImplementedError
    end

    # Deletes a tag of the package header
    # @param [Number] tag Tag
    def delete_tag(_tag)
      raise NotImplementedError
    end

    # @return a formated string
    # @example
    #   pkg.sprintf("%{name}") => "apache2"
    def sprintf(fmt)
      error = ::FFI::MemoryPointer.new(:pointer, 1)
      val = RPM::C.headerFormat(@hdr, fmt, error)
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

      return [] if basenames.nil?

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

      basenames.each_with_index do |_basename, i|
        file = RPM::File.new("#{dirnames[diridxs[i]]}#{basenames[i]}",
                             md5list[i],
                             linklist[i],
                             sizelist[i],
                             mtimelist[i],
                             ownerlist[i],
                             grouplist[i],
                             rdevlist[i],
                             modelist[i],
                             flaglist.nil? ? RPM::C::FileAttrs[:none] : flaglist[i],
                             statelist.nil? ? RPM::C::FileState[:normal] : statelist[i])
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

      nametd = ::FFI::AutoPointer.new(RPM::C.rpmtdNew, Package.method(:release_td))
      versiontd = ::FFI::AutoPointer.new(RPM::C.rpmtdNew, Package.method(:release_td))
      flagtd = ::FFI::AutoPointer.new(RPM::C.rpmtdNew, Package.method(:release_td))

      min = RPM::C::HEADERGET_MINMEM
      return deps if RPM::C.headerGet(@hdr, nametag, nametd, min) != 1
      return deps if RPM::C.headerGet(@hdr, versiontag, versiontd, min) != 1
      return deps if RPM::C.headerGet(@hdr, flagtag, flagtd, min) != 1

      RPM::C.rpmtdInit(nametd)
      while RPM::C.rpmtdNext(nametd) != -1
        deps << klass.new(RPM::C.rpmtdGetString(nametd),
                          RPM::Version.new(RPM::C.rpmtdNextString(versiontd)),
                          RPM::C.rpmtdNextUint32(flagtd).read_uint, self)
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
      dependencies(RPM::Conflict, :conflictname, :conflictversion, :conflictflags)
    end

    # @return [Array<RPM::Obsolete>] Obsoletes list for this package
    def obsoletes
      dependencies(RPM::Obsolete, :obsoletename, :obsoleteversion, :obsoleteflags)
    end

    # @return [Array<RPM::Changelog>] changelog of the package as an array
    def changelog
      entries = []
      nametd = ::FFI::AutoPointer.new(RPM::C.rpmtdNew, Package.method(:release_td))
      timetd = ::FFI::AutoPointer.new(RPM::C.rpmtdNew, Package.method(:release_td))
      texttd = ::FFI::AutoPointer.new(RPM::C.rpmtdNew, Package.method(:release_td))

      min = RPM::C::HEADERGET_MINMEM
      return deps if RPM::C.headerGet(@hdr, :changelogtime, timetd, min) != 1
      return deps if RPM::C.headerGet(@hdr, :changelogname, nametd, min) != 1
      return deps if RPM::C.headerGet(@hdr, :changelogtext, texttd, min) != 1

      RPM::C.rpmtdInit(timetd)
      while RPM::C.rpmtdNext(timetd) != -1
        entry = RPM::ChangeLog.new
        entry.time = RPM::C.rpmtdGetUint32(timetd)
        entry.name = RPM::C.rpmtdNextString(nametd)
        entry.text = RPM::C.rpmtdNextString(texttd)
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
      tagc = ::FFI::AutoPointer.new(RPM::C.rpmtdNew, Package.method(:release_td))

      return nil if RPM::C.headerGet(ptr, tag, tagc,
                                     RPM::C::HEADERGET_MINMEM) == 0

      type = RPM::C.rpmtdType(tagc)
      count = RPM::C.rpmtdCount(tagc)
      ret_type = RPM::C.rpmTagGetReturnType(tag)

      method_name = case type
                    when :int8_type, :char_type, :int16_type, :int32_type, :int64_type then :rpmtdGetNumber
                    when :string_type, :string_array_type, :bin_type then :rpmtdGetString
                    else raise NotImplementedError, "Don't know how to retrieve type '#{type}'"
                    end

      is_array = if count > 1 then true
                 elsif ret_type == :array_return_type then true
                 elsif type == :string_array_type then true
                 else false
                 end

      if is_array
        ret = []
        RPM::C.rpmtdInit(tagc)
        ret << RPM::C.send(method_name, tagc) while RPM::C.rpmtdNext(tagc) != -1
        return ret
      end

      RPM::C.send(method_name, tagc)
    end

    # @return [String] This package name
    def name
      self[:name]
    end

    # @return [String] This package architecture
    def arch
      self[:arch]
    end

    # TODO: signature

    # @return [Version] Version for this package
    def version
      Version.new(self[:version], self[:release], self[:epoch])
    end

    # String representation of the package: "name-version-release-arch"
    # @return [String]
    def to_s
      return '' if name.nil?
      return name if version.nil?
      return "#{name}-#{version}" if arch.nil?
      "#{name}-#{version}-#{arch}"
    end

    def self.open(filename)
      Package.new(filename)
    end

    # @visibility private
    def self.release(ptr)
      RPM::C.headerFree(ptr)
    end

    # @visibility private
    def self.release_td(ptr)
      RPM::C.rpmtdFree(ptr)
    end

    # @visibility private
    def initialize(what)
      case what
      when String then initialize_from_filename(what)
      else initialize_from_header(what)
      end
    end

    # @visibility private
    def initialize_from_header(hdr = nil)
      if hdr.nil?
        @hdr = ::FFI::AutoPointer.new(RPM::C.headerNew, Header.method(:release))
      elsif hdr.is_a?(::FFI::Pointer)
        # ref
        hdr = RPM::C.headerLink(hdr)
        @hdr = ::FFI::AutoPointer.new(hdr, Package.method(:release))
      else
        raise "Can't initialize header with '#{hdr}'"
      end
    end

    def initialize_from_filename(filename)
      # it sucks not using the std File.open here
      hdr = ::FFI::MemoryPointer.new(:pointer)
      fd = nil
      begin
        fd = RPM::C.Fopen(filename, 'r')
        raise "#{filename} : #{RPM::C.Fstrerror(fd)}" if RPM::C.Ferror(fd) != 0
        RPM.transaction do |ts|
          rc = RPM::C.rpmReadPackageFile(ts.ptr, fd, filename, hdr)
        end
      ensure
        RPM::C.Fclose(fd) unless fd.nil?
      end
      initialize_from_header(hdr.get_pointer(0))
    end

    # @return [RPM::C::Header] header pointer
    # @visibility private
    def ptr
      @hdr
    end
  end
end
