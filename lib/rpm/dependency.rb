require 'rpm'

module RPM

  class Dependency

    def initialize(name, version, flags, owner)

      raise TypeError.new("illegal argument type")
        unless version.is_a?(RPM::Version)

      @name = name
      @version = version
      @flags = flags
      @owner = owner
    end

  end

  class Provide < Dependency

    def initialize(name, version, flags, owner)
      @nametag = RPM::Tag[:providename]
      @versiontag = RPM::Tag[:provideversion]
      @flagstag = RPM::Tag[:provideflags]
    end

  end

  class Require < Dependency

    def initialize(name, version, flags, owner)
      @nametag = RPM::Tag[:requirename]
      @versiontag = RPM::Tag[:requireversion]
      @flagstag = RPM::Tag[:requireflags]
    end

  end

  class Conflict < Dependency

    def initialize(name, version, flags, owner)
      @nametag = RPM::Tag[:conflictname]
      @versiontag = RPM::Tag[:conflictversion]
      @flagstag = RPM::Tag[:conflictflags]
    end

  end

  class Conflict < Dependency

    def initialize(name, version, flags, owner)
      @nametag = RPM::Tag[:conflictname]
      @versiontag = RPM::Tag[:conflictversion]
      @flagstag = RPM::Tag[:conflictflags]
    end

  end

end