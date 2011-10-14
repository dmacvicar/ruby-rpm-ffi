require File.join(File.dirname(__FILE__), 'helper')

class RPM_Lib_Tests < Test::Unit::TestCase

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
      hdr = RPM::Lib.headerLink(hdr)
      puts RPM::Lib.headerGetAsString(hdr, :name)
    end
    RPM::Lib.rpmdbFreeIterator(it)

    hdrs.each do |h|
      puts RPM::Lib.headerGetAsString(h, :name)
    end

  end

end
