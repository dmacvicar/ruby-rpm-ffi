
module RPM
  class Dependency
    # @return [String] dependency name
    attr_accessor :name
    # @return [String] dependency version
    attr_accessor :version
    # @return [String] dependency flags
    attr_accessor :flags
    # @return [Package] package this dependency belongs to
    attr_accessor :owner

    attr_accessor :nametag
    attr_accessor :versiontag
    attr_accessor :flagstag

    def initialize(name, version, flags, owner)
      RPM::Utils.check_type(version, RPM::Version)

      @name = name
      @version = version
      @flags = flags
      @owner = owner
    end

    # @param [Package, Dependency, Version] other
    # @return [Boolean] true if +other+ satisfies this dependency
    def satisfy?(other)
      case other
      when RPM::Package then
        other.provides.each do |prov|
          return true if satisfy?(prov)
        end
        false
      when RPM::Dependency then
        RPM::C.rpmdsCompare(
          RPM::C.rpmdsSingle(:providename, other.name,
                             other.version.to_vre, other.flags),
          RPM::C.rpmdsSingle(:providename, name,
                             version.to_vre, flags)
        ) != 0
      when RPM::Version then
        RPM::C.rpmdsCompare(
          RPM::C.rpmdsSingle(:providename, name,
                             other.to_vre, other.to_vre.empty? ? 0 : :equal),
          RPM::C.rpmdsSingle(:providename, name,
                             version.to_vre, flags)
        ) != 0
      else
        raise(TypeError, "#{other} is not a Version or Dependency")
      end
    end

    # @return [Boolean] true if '<' or '=<' are used to compare the version
    def lt?
      flags & RPM::SENSE[:less]
    end

    # @return [Boolean] true if '>' or '>=' are used to compare the version
    def gt?
      flags & RPM::SENSE[:greater]
    end

    # @return [Boolean] true if '=', '=<' or '>=' are used to compare the version
    def eq?
      flags & RPM::SENSE[:equal]
    end

    # @return [Boolean] true if '=<' is used to compare the version
    def le?
      (flags & RPM::SENSE[:less]) && (flags & RPM::SENSE[:equal])
    end

    # @return [Boolean] true if '>=' is used to compare the version
    def ge?
      (flags & RPM::SENSE[:greater]) && (flags & RPM::SENSE[:equal])
    end

    # @return [Boolean] true if this is a pre-requires
    def pre?
      flags & RPM::SENSE[:prereq]
    end
  end

  class Provide < Dependency
    def initialize(name, version, flags, owner)
      super(name, version, flags, owner)
      @nametag = RPM::TAG[:providename]
      @versiontag = RPM::TAG[:provideversion]
      @flagstag = RPM::TAG[:provideflags]
    end
  end

  class Require < Dependency
    def initialize(name, version, flags, owner)
      super(name, version, flags, owner)
      @nametag = RPM::TAG[:requirename]
      @versiontag = RPM::TAG[:requireversion]
      @flagstag = RPM::TAG[:requireflags]
    end
  end

  class Conflict < Dependency
    def initialize(name, version, flags, owner)
      super(name, version, flags, owner)
      @nametag = RPM::TAG[:conflictname]
      @versiontag = RPM::TAG[:conflictversion]
      @flagstag = RPM::TAG[:conflictflags]
    end
  end

  class Obsolete < Dependency
    def initialize(name, version, flags, owner)
      super(name, version, flags, owner)
      @nametag = RPM::TAG[:obsoletename]
      @versiontag = RPM::TAG[:obsoleteversion]
      @flagstag = RPM::TAG[:obsoleteflags]
    end
  end
end
