require File.join(File.dirname(__FILE__), 'helper')

class RPM_Lib_Tests < Test::Unit::TestCase

  def test_lib_lib
    assert_kind_of String, RPM::FFI.RPMVERSION
    # "x.y.z"
    assert(RPM::FFI.RPMVERSION.size >= 5)
    assert_kind_of Fixnum, RPM::FFI.rpm_version_code
    # >= 4.0.0
    assert(RPM::FFI.rpm_version_code >= ((4 << 16) + (0 << 8) + (0 << 0)))
  end

  def test_lib_header
    ptr = RPM::FFI.headerNew
    RPM::FFI.headerFree(ptr)
  end

  def test_lib_ts
    ts = RPM::FFI.rpmtsCreate
    RPM::FFI.rpmtsSetRootDir(ts, "/")
    it = RPM::FFI.rpmtsInitIterator(ts, 0, nil, 0)
    hdrs = []
    while (not (hdr = RPM::FFI.rpmdbNextIterator(it)).null?)
      hdrs << hdr
      assert_kind_of String, RPM::FFI.headerGetAsString(hdr, :name)
    end
    RPM::FFI.rpmdbFreeIterator(it)

  end

  def test_lib_macros
    assert_kind_of String, RPM::FFI.MACROFILES
  end

end
