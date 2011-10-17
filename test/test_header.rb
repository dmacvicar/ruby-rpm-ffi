require File.join(File.dirname(__FILE__), 'helper')

class RPM_Header_Tests < Test::Unit::TestCase

  def test_open
    hdr = RPM::Header.open(fixture('simple-1.0-0.x86_64.rpm'))
    assert_kind_of RPM::Header, hdr
    assert_equal 'simple', hdr[:name]
    assert_equal 'x86_64', hdr[:arch]

    assert_equal '1.0-0', hdr.version
  end

end
