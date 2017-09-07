
module RPM
  class Version
    include Comparable

    # Parses a "epoch:version-release" string
    # @return [Array] tuple [epoch, version, release]
    def self.parse_evr(evr)
      raise ArgumentError, "version can't be nil" if evr.nil?
      version = evr
      epoch = nil
      release = nil

      idx = version.rindex('-')
      if idx
        release = version[idx + 1..-1]
        version = version[0..idx - 1]
      end

      idx = version.index(/\D/)
      if idx && version[idx] == ':'
        epoch = version[0..idx - 1]
        version = version[idx + 1..-1]
      end
      [epoch ? epoch.to_i : nil, version, release]
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
      when 0
        raise(ArgumentError('wrong number of arguments (0 for 1..3)'))
      when 1
        RPM::Utils.check_type(argv[0], String)
        @e, @v, @r = RPM::Version.parse_evr(argv[0])
      when 2
        # (vr, e)
        RPM::Utils.check_type(argv[0], String)
        @e, @v, @r = RPM::Version.parse_evr(argv[0])
        raise(TypeError, 'illegal argument value') unless e.nil?
        @e = argv[1].to_i
      when 3
        RPM::Utils.check_type(argv[0], String)
        RPM::Utils.check_type(argv[1], String)
        @v = argv[0]
        @r = argv[1]
        @e = argv[2].to_i
      else
        raise(ArgumentError("too many arguments (#{args.size} for 1..3)"))
      end
    end

    # @return [String] the version component
    attr_reader :v

    # @return [String] the release component
    #   or +nil+
    attr_reader :r

    # @return [String] the epoch component
    #   or +nil+
    attr_reader :e

    # Comparison between versions
    # @param [Version] other
    # @return [Number] -1 if +other+ is greater than, 0 if +other+ is equal to,
    #   and +1 if other is less than version.
    #
    # @example
    #   v1 = RPM::Version.new("3.0-0",1)
    #   v2 = RPM::Version.new("3.1-0",1)
    #   v1 <=> v2
    #   => -1
    #
    def <=>(other)
      RPM::Utils.check_type(other, RPM::Version)
      ret = RPM::C.rpmvercmp(to_vre_epoch_zero, other.to_vre_epoch_zero)
    end

    # @param [Version] other Version to compare against
    # @return [Boolean] true if the version is newer than +other+
    def newer?(other)
      self > other
    end

    # @param [Version] other Version to compare against
    # @return [Boolean] true if the version is older than +other+
    def older?(other)
      self < other
    end

    # String representation in the form "v-r"
    # @return [String]
    # @note The epoch is not included
    def to_vr
      vr = @r.nil? ? @v.to_s : "#{@v}-#{@r}"
    end

    # String representation in the form "e:v-r"
    # @return [String]
    # @note The epoch is included if present
    def to_vre(_opts = {})
      vr = to_vr
      vre = @e.nil? ? vr : "#{@e}:#{vr}"
    end

    # Alias for +to_vr+
    # @see Version#to_vr
    def to_s
      to_vr
    end

    # Hash based on the version content
    # @return [String]
    def hash
      h = @e.nil? ? 0 : @e
      h = (h << 1) ^ @r.hash
      h = (h << 1) ^ @v.hash
    end

    # String representation in the form "e:v-r"
    # @return [String]
    # @note The epoch is included always. As 0 if not present
    def to_vre_epoch_zero
      vr = to_vr
      vre = @e.nil? ? "0:#{vr}" : "#{@e}:#{vr}"
    end
  end
end
