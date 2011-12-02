require 'test/unit'
dir = File.dirname(__FILE__)
require dir + '/../init'

class TestType < Test::Unit::TestCase
  include Glyde

  def setup
    HasType::Parser.send(:def_core_methods)
  end

  def teardown
    HasType::Parser.send(:undef_core_methods)
  end

  # This makes no sense.
  def ___test_product_pipe_makes_sum
    p = Integer * String
    s = p | Symbol
    # Probably this should raise an error.
    # We want HasType::Product to exist ONLY as the entire LHS.
    # (Perhaps as entire RHS, too?)
    # A Product cannot be Summed with something other than another Product,
    # unless perhaps a HasType::Product is used to mean any Tuple
    # (Array of a set number of values).
    assert s.is_a?(HasType::Sum)
    assert s.validate([1, 'a'])
    assert s.validate([:a])
  end

  def test_product_star_adds_to_product
    p1 = Integer * String
    p2 = p1 * Symbol
    assert p2.is_a?(HasType::Product)
    assert_equal 3, p2.arity
    assert p2.validate([1, 'a', :a])
  end

  def test_sum_star_makes_product
    s = String | Symbol
    p = s * Integer
    assert p.is_a?(HasType::Product)
    assert_equal 2, p.arity
    assert p.validate([:a, 1])
    assert p.validate(['a', 1])
  end

  def test_sum_pipe_adds_to_sum
    s1 = String | Symbol
    s2 = s1 | Integer
    assert s2.is_a?(HasType::Sum)
    assert s2.validate('a')
    assert s2.validate(:a)
    assert s2.validate(1)
  end

end
