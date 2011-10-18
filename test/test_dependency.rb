require File.join(File.dirname(__FILE__), 'helper')
require 'rpm/compat'

class RPM_Dependency_Tests < Test::Unit::TestCase
    
    EQ = RPM::SENSE_EQUAL
    LT = RPM::SENSE_LESS
    GT = RPM::SENSE_GREATER

    def test_satisfy
        prv = provide("foo", "2", "1", 0, EQ)
        req = require("foo", "1", "1", 0, EQ|GT)
        assert(req.satisfy?(prv))
        assert(prv.satisfy?(req))
        
        # Different names don't overlap
        prv = provide("foo", "2", "1", 0, EQ)
        req = require("bar", "1", "1", 0, EQ|GT)
        assert(! req.satisfy?(prv))
    end

    def provide(name, v, r, e, sense)
        RPM::Provide.new(name, RPM::Version.new(v, r, e), sense, nil)
    end

    def require(name, v, r, e, sense)
        RPM::Require.new(name, RPM::Version.new(v, r, e), sense, nil)
    end
end
