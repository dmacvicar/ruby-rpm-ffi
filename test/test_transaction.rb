require File.join(File.dirname(__FILE__), 'helper')
require 'tmpdir'

class RPM_Transaction_Tests < Test::Unit::TestCase

  def test_install
    
    filename = 'simple-1.0-0.i586.rpm'
    pkg = RPM::Package.open(fixture(filename))

    Dir.mktmpdir do |dir|
      RPM.transaction do |t|
        assert_equal "/", t.root_dir
        t.root_dir = dir
        assert_equal dir + '/', t.root_dir
        
        t.flags = RPM::TRANS_FLAG_TEST
        
        t.install(pkg, filename)
        t.commit
      end
    end

  end

end
