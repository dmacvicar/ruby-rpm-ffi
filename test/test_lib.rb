require File.join(File.dirname(__FILE__), 'helper')

class RPM_Lib_Tests < Test::Unit::TestCase

  def test_lib_lib
    assert_kind_of String, RPM::Lib.RPMVERSION
    # "x.y.z"
    assert(RPM::Lib.RPMVERSION.size >= 5)
    assert_kind_of Fixnum, RPM::Lib.rpm_version_code
    # >= 4.0.0
    assert(RPM::Lib.rpm_version_code >= ((4 << 16) + (0 << 8) + (0 << 0)))
  end

  def test_lib_header
    ptr = RPM::Lib.headerNew
    RPM::Lib.headerFree(ptr)
  end

  def test_lib_ts
    ts = RPM::Lib.rpmtsCreate
    RPM::Lib.rpmtsSetRootDir(ts, "/")
    it = RPM::Lib.rpmtsInitIterator(ts, 0, nil, 0)
    hdrs = []
    while (not (hdr = RPM::Lib.rpmdbNextIterator(it)).null?)
      hdrs << hdr
      assert_kind_of String, RPM::Lib.headerGetAsString(hdr, :name)
    end
    RPM::Lib.rpmdbFreeIterator(it)

  end

  def test_lib_macros
    assert_kind_of String, RPM::Lib.MACROFILES
  end

end
