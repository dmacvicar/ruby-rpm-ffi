require File.join(File.dirname(__FILE__), 'helper')

class RPM_RPM_Tests < Test::Unit::TestCase

  def test_gc
    RPM.transaction do |t|

    end
  end

  def test_enum
    assert RPM::Tag[:not_found]
  end

  def test_iterator
    RPM.transaction do |t|
      t.each do |pkg|
        puts pkg[:name]
      end
    end
  end

  def test_macro_read
    assert_equal '/usr', RPM['_usr']
  end

  #def test_macro_write
  #  RPM['hoge'] = 'hoge'
  #  assert_equal( RPM['hoge'], 'hoge' )
  #end # def test_macro_write


end # class RPM_RPM_Tests < Test::Unit::TestCase
