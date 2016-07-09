
module RPM
  class Problem
    def self.release(ptr)
      RPM::C.rpmProblemFree(ptr)
    end

    # Creates a problem from an existing C pointer, refcounting it
    # first.
    # @param [FFI::Pointer] ptr existing C pointer
    # @return [RPM::Problem] wrapped object
    def self.from_ptr(ptr)
      case ptr
      when FFI::Pointer
        new(FFI::AutoPointer.new(RPM::C.rpmProblemLink(ptr), Problem.method(:release)))
      else
        raise "Can't initialize header with '#{ptr}'"
      end
    end

    # Create a problem item.
    # @param [RPM::ProblemType] type problem type
    # @param [String] pkg_nver name-version-edition-release of the related package
    # @param [String] key key of the related package
    # @param [String] alt_nver name-version-edition-release of the other related package
    # @param [String] str generic data string from a problem
    def self.create(type, pkg_nevr, key, alt_nevr, str, number)
      ptr = ::FFI::AutoPointer.new(RPM::C.rpmProblemCreate(type, pkg_nevr, key, alt_nevr, str, number), Problem.method(:release))
      new(ptr)
    end

    # @visibility private
    def initialize(ptr)
      @ptr = ptr
    end

    # @return [RPM::ProblemType] type of problem (dependency, diskpace etc).
    def type
      RPM::C.rpmProblemGetType(@ptr)
    end

    # @return [String] filename or python object address of a problem.
    def key
      RPM::C.rpmProblemGetKey(@ptr).read_string
    end

    # @return [String] a generic data string from a problem.
    def str
      RPM::C.rpmProblemGetStr(@ptr)
    end

    # @return [String] formatted string representation of a problem
    def to_s
      RPM::C.rpmProblemString(@ptr)
    end

    # @return [Fixnum] compare two problems for equality.
    def <=>(other)
      RPM::C.rpmProblemCompare(@ptr, other.ptr)
    end

    # @visibility private
    attr_reader :ptr
  end
end
