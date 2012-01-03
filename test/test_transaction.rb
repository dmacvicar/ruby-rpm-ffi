require File.join(File.dirname(__FILE__), 'helper')
require 'tmpdir'

class RPM_Transaction_Tests < Test::Unit::TestCase

  def test_flags
    RPM.transaction do |t|
      assert_equal RPM::TRANS_FLAG_NONE, t.flags
      t.flags = RPM::TRANS_FLAG_TEST
      assert_equal RPM::TRANS_FLAG_TEST, t.flags
    end
  end

  def test_iterator
    RPM.transaction do |t|
      it = t.init_iterator(nil, nil)
      assert_kind_of RPM::MatchIterator, it
      #assert it.count > 0
    end

    RPM.transaction do |t|
      it = t.init_iterator(nil, nil)
      it.regexp(:name, :glob, '*audio*')
      it.each do |pkg| 
        assert pkg.name.include?("audio"), "'#{pkg.name}' contains 'audio'"
      end
    end
  end

  # FIXME this is not working
  def test_iterator_version
    RPM.transaction do |t|
      it = t.init_iterator(nil, nil)
      it.version(RPM::Version.new('2.1'))
      it.each do |pkg| 
        puts pkg
      end
    end
  end 

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
        #t.commit
      end
    end

  end

end
