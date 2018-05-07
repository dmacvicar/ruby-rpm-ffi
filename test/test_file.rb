require File.join(File.dirname(__FILE__), 'helper')

class RPMFileTests < Minitest::Test
  def test_link_to
    f = RPM::File.new('path', 'md5sum', nil, 42, 1,
                      'owner', 'group', 43, 0o777, 44, 45)
    assert_equal(nil, f.link_to)
    f = RPM::File.new('path', 'md5sum', 'link_to', 42, 1,
                      'owner', 'group', 43, 0o777, 44, 45)
    assert_equal('link_to', f.link_to)
  end

  def test_flags
    f = RPM::File.new('path', 'md5sum', nil, 42, 1,
                      'owner', 'group', 43, 0o777, 44, 45)
    f.config?
    f.doc?
    f.is_missingok?
    f.is_noreplace?
    f.is_specfile?
    f.ghost?
    f.license?
    f.readme?
    f.replaced?
    f.notinstalled?
    f.netshared?

    assert_raises NotImplementedError do
      f.exclude?
    end

    assert_raises NotImplementedError do
      f.donotuse?
    end
  end
end
