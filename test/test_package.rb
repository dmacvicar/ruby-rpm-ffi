require File.join(File.dirname(__FILE__), 'helper')

class RPM_Header_Tests < Test::Unit::TestCase

  def test_create

    pkg = RPM::Package.create('foo', '1.0')
    assert_equal 'foo', pkg.name
    assert_equal '(none)', pkg.signature
  end

  def test_open
    
    hdr = RPM::Package.open(fixture('simple-1.0-0.i586.rpm'))
    
    assert_equal '3fe8fc4ca14571eaa2fedbdab1f0308f', hdr.signature

    assert_kind_of RPM::Package, hdr
    assert_equal 'simple', hdr[:name]
    assert_equal 'i586', hdr[:arch]
    assert_equal '1.0-0', hdr.version

    backup_lang = ENV['LANG']

    ENV['LANG'] = 'C'
    assert_equal 'Simple dummy package', hdr[:summary]
    assert_equal 'Dummy package', hdr[:description]
    
    ENV['LANG'] = 'es'
    assert_equal 'Paquete simple de muestra', hdr[:summary]
    assert_equal 'Paquete de muestra', hdr[:description]

    ENV['LANG'] = backup_lang
    
    # Arrays
    assert_equal ["root", "root"], hdr[:fileusername]
    assert_equal [6, 5], hdr[:filesizes]
  end

end
