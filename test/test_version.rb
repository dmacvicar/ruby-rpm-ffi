require File.join(File.dirname(__FILE__), 'helper')

class RPMVersionTests < Minitest::Test
  def setup
    @a = RPM::Version.new('1.0.0-0.1m')
    @b = RPM::Version.new('0.9.0-1m')
    @c = RPM::Version.new('1.0.0-0.11m')
    @d = RPM::Version.new('0.9.0-1m', 1)
  end

  def test_parse_evr
    assert_equal [23, '1.0.3', '1suse'],
                 RPM::Version.parse_evr('23:1.0.3-1suse')
    assert_equal [nil, '1.0', nil],
                 RPM::Version.parse_evr('1.0')
    assert_equal [nil, '2.0', '3'],
                 RPM::Version.parse_evr('2.0-3')
  end

  def test_version_compare
    assert(@a > @b)
    assert(@a < @c)
    assert(@a < @d)
  end

  def test_version_newer?
    assert(@a.newer?(@b))
    assert(@c.newer?(@a))
    assert(@d.newer?(@a))
    assert(!@a.newer?(@a))
  end

  def test_version_older?
    assert(@b.older?(@a))
    assert(@a.older?(@c))
    assert(@a.older?(@d))
    assert(!@a.older?(@a))
  end

  def test_vre
    assert_equal('0.9.0', @d.v)
    assert_equal('1m', @d.r)
    assert_equal(1, @d.e)
  end

  def test_to_s
    assert_equal('0.9.0-1m', @b.to_s)
    assert_equal('0.9.0-1m', @d.to_s)
  end

  def test_to_vre
    assert_equal('0.9.0-1m', @b.to_vre)
    assert_equal('1:0.9.0-1m', @d.to_vre)
  end

  def test_epoch_none_zero
    v1 = RPM::Version.new('1-2')
    v2 = RPM::Version.new('0:1-2')
    assert_nil v1.e
    assert_equal(0, v2.e)
    assert(v1 == v2)
    assert_equal(v1.hash, v2.hash)
  end
end
