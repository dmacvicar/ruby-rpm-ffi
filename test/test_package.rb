require File.join(File.dirname(__FILE__), 'helper')

class RPMHeaderTests < Minitest::Test
  def test_create
    pkg = RPM::Package.create('foo', RPM::Version.new('1.0'))
    assert_equal 'foo', pkg.name
    assert_equal '(none)', pkg.signature
  end

  def test_open
    pkg = RPM::Package.open(fixture('simple-1.0-0.i586.rpm'))

    req = RPM::Require.new('simple', RPM::Version.new('1.0', '0'), RPM::SENSE_GREATER | RPM::SENSE_EQUAL, nil)
    assert req.satisfy?(pkg)

    assert_equal 'simple-1.0-0-i586', pkg.to_s

    assert_equal '3b5f9d468c877166532c662e29f43bc3', pkg.signature

    assert_kind_of RPM::Package, pkg
    assert_equal 'simple', pkg[:name]
    assert_equal 'i586', pkg[:arch]
    assert_kind_of RPM::Version, pkg.version
    assert_equal '1.0-0', pkg.version.to_s

    backup_lang = ENV['LC_ALL']

    ENV['LC_ALL'] = 'C'
    assert_equal 'Simple dummy package', pkg[:summary]
    assert_equal 'Dummy package', pkg[:description]

    ENV['LC_ALL'] = 'es_ES.UTF-8'
    assert_equal 'Paquete simple de muestra', pkg[:summary]
    assert_equal 'Paquete de muestra', pkg[:description]

    ENV['LC_ALL'] = backup_lang

    # Arrays
    assert_equal %w[root root], pkg[:fileusername]
    assert_equal [6, 5], pkg[:filesizes]

    assert pkg.provides.map(&:name).include?('simple(x86-32)')
    assert pkg.provides.map(&:name).include?('simple')

    assert pkg.files.map(&:path).include?('/usr/share/simple/README')
    assert pkg.files.map(&:path).include?('/usr/share/simple/README.es')

    assert pkg.conflicts.empty?
    assert pkg.requires.map(&:name).include?('rpmlib(PayloadIsLzma)')
    assert pkg.obsoletes.empty?

    file = pkg.files.select { |x| x.path == '/usr/share/simple/README' }.first
    assert_nil file.link_to
    assert !file.symlink?

    assert_equal ['- Fix something', '- Fix something else'], pkg.changelog.map(&:text)
  end

  def test_dependencies
    pkg = RPM::Package.open(fixture('simple_with_deps-1.0-0.i586.rpm'))
    assert_equal 'simple_with_deps', pkg.name

    assert pkg.provides.map(&:name).include?('simple_with_deps(x86-32)')
    assert pkg.provides.map(&:name).include?('simple_with_deps')

    assert pkg.requires.map(&:name).include?('a')
    b = pkg.requires.find { |x| x.name == 'b' }
    assert b
    assert_equal '1.0', b.version.to_s

    assert pkg.conflicts.map(&:name).include?('c')
    assert pkg.conflicts.map(&:name).include?('d')

    assert pkg.obsoletes.map(&:name).include?('f')
  end
end
