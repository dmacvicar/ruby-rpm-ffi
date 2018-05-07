require_relative('helper')
require 'rpm/compat'

class RPMDependencyTests < Minitest::Test
  EQ = RPM::SENSE_EQUAL
  LT = RPM::SENSE_LESS
  GT = RPM::SENSE_GREATER

  def test_satisfy
    prv = provides('foo', '2', '1', 0, EQ)
    req = requires('foo', '1', '1', 0, EQ | GT)
    assert(req.satisfy?(prv))
    assert(prv.satisfy?(req))

    # Different names don't overlap
    prv = provides('foo', '2', '1', 0, EQ)
    req = requires('bar', '1', '1', 0, EQ | GT)
    assert(!req.satisfy?(prv))
  end

  def provides(name, v, r, e, sense)
    RPM::Provide.new(name, RPM::Version.new(v, r, e), sense, nil)
  end

  def requires(name, v, r, e, sense)
    RPM::Require.new(name, RPM::Version.new(v, r, e), sense, nil)
  end
end
