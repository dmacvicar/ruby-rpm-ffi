
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
      return RPM::Package.new(pkg_ptr) unless pkg_ptr.null?
      nil
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

    alias regexp set_iterator_re

    def set_iterator_version(version)
      unless version.is_a?(RPM::Version)
        raise TypeError, 'illegal argument type'
      end

      set_iterator_re(:version, :default, version.v)
      set_iterator_re(:release, :default, version.r) if version.r
      self
    end

    alias version set_iterator_version

    def get_iterator_count
      RPM::C.rpmdbGetIteratorCount(@ptr)
    end

    alias count get_iterator_count
    alias length get_iterator_count
  end
end
