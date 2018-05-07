require File.join(File.dirname(__FILE__), 'helper')

class RPMLibTests < Minitest::Test
  def test_lib_lib
    assert_kind_of String, RPM::C.RPMVERSION
    # "x.y.z"
    assert(RPM::C.RPMVERSION.size >= 5)
    assert_kind_of Integer, RPM::C.rpm_version_code
    # >= 4.0.0
    assert(RPM::C.rpm_version_code >= ((4 << 16) + (0 << 8) + (0 << 0)))
  end

  def test_lib_header
    ptr = RPM::C.headerNew
    RPM::C.headerFree(ptr)
  end

  def test_lib_ts
    ts = RPM::C.rpmtsCreate
    RPM::C.rpmtsSetRootDir(ts, '/')
    it = RPM::C.rpmtsInitIterator(ts, 0, nil, 0)
    hdrs = []
    until (hdr = RPM::C.rpmdbNextIterator(it)).null?
      hdrs << hdr
      assert_kind_of String, RPM::C.headerGetAsString(hdr, :name)
    end
    RPM::C.rpmdbFreeIterator(it)
  end

  def test_lib_macros
    assert_kind_of String, RPM::C.MACROFILES
  end
end
