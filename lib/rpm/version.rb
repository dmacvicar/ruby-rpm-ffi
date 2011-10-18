require 'rpm'

module RPM

  class Version


    def self.parse_evr(evr)
      version = evr
      epoch = nil
      release = nil

      idx = version.rindex(?-)
      version, release = version[0..idx-1], version[idx+1..-1] if idx
      
      idx = version.index(/\D/)
      if (version[idx] == ?:)
        epoch = version[0..idx-1]
        version = version[idx+1..-1]
      end
      return epoch, version, release
    end

    #
    # @overload new(vr, e = nil)
    #   Creates a version object from a string representation
    #   @param [String] vr version and release in the form "v-r"
    #   @param [Number] e epoch
    #   @return [Version]
    # @overload new(v, r, e = nil)
    #   Creates a version object from a string representation
    #   @param [String] v version
    #   @param [String] r release
    #   @param [Number] e epoch
    #   @return [Version]
    # @example
    #   RPM:: Version.new "1.0.0-3"
    #   RPM:: Version.new "1.04"
    #   RPM:: Version.new "1.0.0-3k", 1
    #   RPM:: Version.new "2.0.3", "5k"
    #
    def initialize(*argv)

      case argv.size
        when 0:
          raise(ArgumentError "wrong number of arguments (0 for 1..3)")
        when 1:
          RPM::Utils.check_type(argv[0], String)
        when 2:

        when 3:
          RPM::Utils.check_type(argv[0], String)
          RPM::Utils.check_type(argv[1], String)
          @v = argv[0]
          @r = argv[1]
          @e = argv[2].to_i
        else
          raise(ArgumentError "too many arguments (#{args.size} for 1..3)")
      end

    end

  end

end
