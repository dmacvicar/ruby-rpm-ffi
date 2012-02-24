require File.join(File.dirname(__FILE__), 'helper')
require 'tmpdir'
require 'pathname'

class RPM_Transaction_Tests < Test::Unit::TestCase

  PACKAGE_FILENAME = 'simple-1.0-0.i586.rpm'

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
      it.each do |sig| 
        puts sig
      end
    end
  end 

  def test_basic_transaction_setters
    Dir.mktmpdir do |dir|
      RPM.transaction do |t|
        assert_equal "/", t.root_dir
        t.root_dir = dir
        assert_equal  dir + '/', t.root_dir
      end
    end

    Dir.mktmpdir do |dir|
      RPM.transaction(dir) do |t|
        assert_equal dir + '/', t.root_dir
      end
    end
  end

  def test_test_flag_install
    filename = 'simple-1.0-0.i586.rpm'
    pkg = RPM::Package.open(fixture(filename))

    Dir.mktmpdir do |dir|
      RPM.transaction(dir) do |t|   
        
        t.flags = RPM::TRANS_FLAG_TEST
        t.install(pkg, fixture(filename))
        t.commit
        
        assert File.exist?(File.join(dir, '/var/lib/rpm/Packages')),
          "rpm db exists"

        assert !File.exist?('/usr/share/simple/README'),
          "package #{pkg} was not installed"
      end
    end
  end

  def test_install_and_remove
    pkg = RPM::Package.open(fixture(PACKAGE_FILENAME))

    Dir.mktmpdir do |dir|
      RPM.transaction(dir) do |t|   
        begin
          t.install(pkg, fixture(PACKAGE_FILENAME))
          t.commit
          
          assert File.exist?(File.join(dir, '/var/lib/rpm/Packages')),
            "rpm db exists"

          assert File.exist?(File.join(dir, '/usr/share/simple/README')),
            "package #{pkg} should be installed"
        ensure
          # Force close so that RPM does not try to do it
          # when the tmpdir is deleted
          t.db.close
        end
      end

      RPM.transaction(dir) do |t|   
        begin

          assert_raise TypeError do
            t.delete(Object.new)
          end

          t.delete(pkg)
          t.commit

          assert !File.exist?(File.join(dir, '/usr/share/simple/README')),
            "package #{pkg} should not be installed"
          
        ensure
          # Force close so that RPM does not try to do it
          # when the tmpdir is deleted
          t.db.close
        end
      end

    end
  end

  def test_install_with_custom_callback
    pkg = RPM::Package.open(fixture(PACKAGE_FILENAME))

    Dir.mktmpdir do |dir|
      RPM.transaction(dir) do |t|
        begin
          t.install(pkg, fixture(PACKAGE_FILENAME))
          t.commit do |data|
            if data.type == :inst_open_file
              next File.open(data.key)
            end
            nil
          end

          assert File.exist?(File.join(dir, '/usr/share/simple/README')),
            "package #{pkg} should be installed"
        ensure
          # Force close so that RPM does not try to do it
          # when the tmpdir is deleted
          t.db.close
        end
      end
    end
  end

end
