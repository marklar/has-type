require 'test/unit'
dir = File.dirname(__FILE__)
require dir + '/../init'

class TestList < Test::Unit::TestCase
  include Glyde

  def setup
    @int_list = HasType::List.new(Integer)
  end

  def test_list
    assert @int_list.validate( [1,2,3,4] )
    assert_raises HasType::TypeMismatch do
      @int_list.validate( [1,'foo'] )
    end
  end

  def test_star_creates_product
    p = @int_list * Integer
    assert p.is_a?(HasType::Product)
    assert_equal 2, p.arity
    assert p.validate( [[1,2,3], 0] )
    assert_raises HasType::TypeMismatch do
      p.validate( [[1,'foo'], 0] )
    end
  end

  def test_pipe_creates_sum
    s = @int_list | Float
    assert s.is_a?(HasType::Sum)
    assert s.validate(0.1)
    assert s.validate( [1,2,3] )
    assert_raises HasType::TypeMismatch do
      s.validate( [0.1, 1] )
    end
    assert_raises HasType::TypeMismatch do
      s.validate('foo')
    end
  end

  def test_rocket_creates_hash
    h = @int_list >> Integer
    assert h.is_a?(Hash)
    assert h.keys.include? @int_list
  end

end
