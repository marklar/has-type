require 'test/unit'
dir = File.dirname(__FILE__)
require dir + '/../init'

class TestHashMap < Test::Unit::TestCase
  include Glyde

  def setup
    @hm = HasType::HashMap.new(Symbol, Integer)
    @val = {:a => 1, :b => 2}
  end

  def test_simple
    assert @hm.validate(@val)
    assert_raises HasType::TypeMismatch do
      @hm.validate(:a => 1, :b => 'foo')
    end
  end

  def test_star_creates_product
    p = @hm * Integer
    assert p.is_a?(HasType::Product)
    assert_equal 2, p.arity
    assert p.validate([@val, 0])
    assert_raises HasType::TypeMismatch do
      p.validate [{:a => 1, 'b' => 2}, 0]
    end
  end

  def test_pipe_creates_sum
    s = @hm | Float
    assert s.is_a?(HasType::Sum)
    assert s.validate(0.1)
    assert s.validate(@val)
    assert_raises HasType::TypeMismatch do
      s.validate [1.0]
    end
    assert_raises HasType::TypeMismatch do
      s.validate('foo')
    end
  end

  def test_rocket_creates_hash
    h = @hm >> Integer
    assert h.is_a?(Hash)
    assert h.keys.include? @hm
  end

end
