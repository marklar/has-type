require 'test/unit'
dir = File.dirname(__FILE__)
require dir + '/../init'

class TestSplat < Test::Unit::TestCase
  include Glyde

  def test_foo
    sp = HasType::Splat.new(Integer)
    assert sp
    assert sp.validate( [1,2,3] )
    assert_raises HasType::TypeMismatch do
      sp.validate( [1, 2, 3.2] )
    end
  end

end
