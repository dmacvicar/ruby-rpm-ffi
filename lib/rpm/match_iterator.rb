
module RPM

  class MatchIterator

    include Enumerable

    # @visibility private
    def self.release(ptr)
      RPM::C.rpmdbFreeIterator(ptr)
    end

    # Creates a managed MatchIterator from a raw pointer
    # @visibility private
    def self.from_ptr(ptr)
      new(::FFI::AutoPointer.new(ptr, MatchIterator.method(:release)))
    end

    def initialize(ptr)
      @ptr = ptr
    end

    def each
      while (pkg = next_iterator)
        yield pkg
      end
    end

    def next_iterator
      pkg_ptr = RPM::C.rpmdbNextIterator(@ptr)
        if !pkg_ptr.null?
          return RPM::Package.new(pkg_ptr)
        end
        return nil;
    end

    # @ return header join key for current position of rpm 
    # database iterator
    def offset
      RPM::C.rpmdbGetIteratorOffset(@ptr)
    end

    def set_iterator_re(tag, mode, string)
      ret = RPM::C.rpmdbSetIteratorRE(@ptr, tag, mode, string)
      raise "Error when setting regular expression '#{string}'" if ret != 0
      self
    end

    alias :regexp :set_iterator_re

    def set_iterator_version(version)
      if not version.is_a?(RPM::Version)
        raise TypeError, 'illegal argument type'
      end

      set_iterator_re(:version, :default, version.v)
      if (version.r)
        set_iterator_re(:release, :default, version.r)
      end
      self
    end

    alias :version :set_iterator_version
    
    def get_iterator_count
      RPM::C.rpmdbGetIteratorCount(@ptr)
    end

    alias :count :get_iterator_count
    alias :length :get_iterator_count

  end
end
