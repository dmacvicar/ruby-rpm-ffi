require_relative('helper')
require 'tmpdir'
require 'pathname'

class RPMTransactionTests < Minitest::Test
  PACKAGE_FILENAME = 'simple-1.0-0.i586.rpm'.freeze

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
      # assert it.count > 0
    end

    RPM.transaction do |t|
      it = t.init_iterator(nil, nil)
      it.regexp(:name, :glob, '*audio*')
      it.each do |pkg|
        assert pkg.name.include?('audio'), "'#{pkg.name}' contains 'audio'"
      end
    end
  end

  # FIXME: this is not working
  def test_iterator_version
    RPM.transaction do |t|
      it = t.init_iterator(nil, nil)
      it.version(RPM::Version.new('2.1'))
      it.each do |sig|
        # FIXME: check that this worked
      end
    end
  end

  def test_basic_transaction_setters
    Dir.mktmpdir do |dir|
      RPM.transaction do |t|
        assert_equal '/', t.root_dir
        t.root_dir = dir
        assert_equal dir + '/', t.root_dir
      end
    end

    Dir.mktmpdir do |dir|
      RPM.transaction(dir) do |t|
        assert_equal dir + '/', t.root_dir
      end
    end
  end

  def test_test_flag_install
    pkg = RPM::Package.open(fixture(PACKAGE_FILENAME))

    Dir.mktmpdir do |dir|
      RPM.transaction(dir) do |t|
        t.flags = RPM::TRANS_FLAG_TEST
        t.install(pkg, fixture(PACKAGE_FILENAME))
        t.commit

        rpmdb_file = RPM::C.rpmvercmp(RPM::C.RPMVERSION, '4.16.0') >= 0 ? 'rpmdb.sqlite' : 'Packages'

        assert File.exist?(File.join(dir, RPM['_dbpath'], rpmdb_file)), 'rpm db exists'
        assert !File.exist?('/usr/share/simple/README'), "package #{pkg} was not installed"
      ensure
        # Force close so that RPM does not try to do it
        # when the tmpdir is deleted
        t.db.close
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

          rpmdb_file = RPM::C.rpmvercmp(RPM::C.RPMVERSION, '4.16.0') >= 0 ? 'rpmdb.sqlite' : 'Packages'

          assert File.exist?(File.join(dir, RPM['_dbpath'], rpmdb_file)), 'rpm db exists'
          assert File.exist?(File.join(dir, '/usr/share/simple/README')), "package #{pkg} should be installed"
        ensure
          # Force close so that RPM does not try to do it
          # when the tmpdir is deleted
          t.db.close
        end
      end

      skip("Commit hangs on package delete")

      RPM.transaction(dir) do |t|
        begin
          assert_raises TypeError do
            t.delete(Object.new)
          end

          t.delete(pkg)
          t.order
          t.clean
          t.commit

          assert !File.exist?(File.join(dir, '/usr/share/simple/README')), "package #{pkg} should not be installed"
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

          t.check do |problem|
            STDERR.puts "Problem: #{problem}"
          end

          t.order
          t.clean

          t.commit do |data|
            next case data.type
                 when :inst_open_file then
                   @f = File.open(data.key, 'r')
                 when :inst_close_file then @f.close
                 end
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
