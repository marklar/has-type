require 'test/unit'
dir = File.dirname(__FILE__)
require dir + '/../init'

class TestProduct < Test::Unit::TestCase
  include Glyde

  def setup
    HasType::Parser.send(:def_core_methods)
    @p = HasType::Product.new(Integer) * String
  end

  def teardown
    HasType::Parser.send(:undef_core_methods)
  end

  def test_ignores_block
    p = Integer * HasType::Block
    assert p.is_a?(HasType::Product)
    assert p.validate([1])
  end

  def test_float
    p = Float * Integer
    assert p.is_a?(HasType::Product)
    assert p.validate( [1.2, 1] )
  end

  def test_block_must_be_last
    p = Integer * HasType::Block * Integer
    assert_raises HasType::Declaration::Error do
      p.validate [1]
    end
  end

  def test_splat
    p = Integer * HasType::Splat.new(String)
    assert p.validate( [1] )
    assert p.validate( [1, 'foo'] )
    assert p.validate( [1, 'foo', 'foo'] )
    assert_raises HasType::TypeMismatch do
      p.validate [1, 'foo', :foo]
    end
  end

  def test_splat_must_be_last_except_block
    p = Integer * HasType::Splat.new(String)
    assert p.validate( [1, 'foo'] )

    p = Integer * HasType::Splat.new(String) * HasType::Block
    assert p.validate( [1, 'foo', 'foo'] )
    
    p = HasType::Splat.new(String) * Integer
    assert_raises HasType::Declaration::Error do
      p.validate ['foo', 1]
    end
  end

  def test_product
    assert_equal 2, @p.arity
    assert @p.validate([1, 'foo'])
    assert_raises HasType::TypeMismatch do
      @p.validate [1, :foo]
    end
  end

  def test_star_lhs_ary
    p = [Integer] * Integer
    assert p.is_a?(HasType::Product)
    assert p.validate( [[2,3,4], 1] )
  end

  def test_star_rhs_ary
    p = Integer * [Integer]
    assert p.is_a?(HasType::Product)
    assert p.validate( [1, [2,3,4]] )
  end

  def test_star_lhs_hash
    p = {String => Float} * Integer
    assert p.is_a?(HasType::Product)
    assert p.validate( [{'a' => 1.1}, 1] )
  end

  def test_star_rhs_hash
    p = Integer * {String => Float}
    assert p.is_a?(HasType::Product)
    assert p.validate( [1, {'a' => 1.1}] )
  end

  def test_star_lhs_bool
    p = HasType::Bool * Integer
    assert p.is_a?(HasType::Product)
    assert p.validate( [true, 1] )
  end

  def test_star_rhs_bool
    p = Integer * HasType::Bool
    assert p.is_a?(HasType::Product)
    assert p.validate( [1, true] )
  end

  def test_star_adds_to_product
    p = @p * Integer
    assert p.is_a?(HasType::Product)
    assert_equal 3, p.arity
    assert p.validate [1, 'foo', 3]
    assert_raises ArgumentError do
      p.validate 1
    end
  end

  def test_rocket_creates_hash
    h = @p >> Integer
    assert h.is_a?(Hash)
    assert h.keys.include? @p
  end

end
