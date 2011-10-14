require File.join(File.dirname(__FILE__), 'helper')

class RPM_Header_Tests < Test::Unit::TestCase

  def test_open
    hdr = RPM::Header.open('/space/packages/rpms/i586/nodejs-0.4.2-1.i586.rpm')
    assert_kind_of RPM::Header, hdr
    assert_equal 'nodejs', hdr[:name]
    assert_equal 'i586', hdr[:arch]
  end

end
