require 'rpm'

module RPM

  class Dependency

    def initialize(name, version, flags, owner)

      RPM::Utils.check_type(version, RPM::Version)
      
      @name = name
      @version = version
      @flags = flags
      @owner = owner
    end

  end

  class Provide < Dependency

    def initialize(name, version, flags, owner)
      @nametag = RPM::TAG[:providename]
      @versiontag = RPM::TAG[:provideversion]
      @flagstag = RPM::TAG[:provideflags]
    end

  end

  class Require < Dependency

    def initialize(name, version, flags, owner)
      @nametag = RPM::TAG[:requirename]
      @versiontag = RPM::TAG[:requireversion]
      @flagstag = RPM::TAG[:requireflags]
    end

  end

  class Conflict < Dependency

    def initialize(name, version, flags, owner)
      @nametag = RPM::TAG[:conflictname]
      @versiontag = RPM::TAG[:conflictversion]
      @flagstag = RPM::TAG[:conflictflags]
    end

  end

  class Conflict < Dependency

    def initialize(name, version, flags, owner)
      @nametag = RPM::TAG[:conflictname]
      @versiontag = RPM::TAG[:conflictversion]
      @flagstag = RPM::TAG[:conflictflags]
    end

  end

end