require File.join(File.dirname(__FILE__), 'helper')

class RPM_File_Tests < Test::Unit::TestCase
  def test_link_to
    f = RPM::File.new("path", "md5sum", nil, 42, 1, 
                      "owner", "group", 43, 0777, 44, 45)
    assert_equal(nil, f.link_to)
    f = RPM::File.new("path", "md5sum", "link_to", 42, 1, 
                      "owner", "group", 43, 0777, 44, 45)
    assert_equal("link_to", f.link_to)
    end
end
