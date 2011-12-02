require 'test/unit'
dir = File.dirname(__FILE__)
require dir + '/../init'

class TestSum < Test::Unit::TestCase
  include Glyde

  def setup
    HasType::Parser.send(:def_core_methods)
    @sum = HasType::Sum.new(Symbol, String)
  end
  
  def teardown
    HasType::Parser.send(:undef_core_methods)
  end

  def test_nil
    s = Integer | nil
    assert s.is_a?(HasType::Sum)
    assert s.validate(1)
    assert s.validate(nil)
  end

  def test_pipe_lhs_ary
    s = [Integer] | Integer
    assert s.is_a?(HasType::Sum)
    assert s.validate([1,2])
    assert s.validate(1)
  end

  def test_pipe_rhs_ary
    s = Integer | [Integer]
    assert s.is_a?(HasType::Sum)
    assert s.validate(1)
    assert s.validate([1,2])
  end

  def test_pipe_lhs_hash
    s = {String => Integer} | Integer
    assert s.is_a?(HasType::Sum)
    assert s.validate('a' => 1)
    assert s.validate(1)
  end

  def test_pipe_rhs_hash
    s = Integer | {String => Integer}
    assert s.is_a?(HasType::Sum)
    assert s.validate(1)
    assert s.validate('a' => 1)
  end

  def test_pipe_lhs_bool
    s = HasType::Bool | Integer
    assert s.is_a?(HasType::Sum)
    assert s.validate(1)
    assert s.validate(false)
  end

  def test_pipe_rhs_bool
    s = Integer | HasType::Bool
    assert s.is_a?(HasType::Sum)
    assert s.validate(1)
    assert s.validate(false)
  end

  def test_list
    assert @sum.validate(:a)
    assert @sum.validate('a')
    assert_raises HasType::TypeMismatch do
      @sum.validate(['a'])
    end
    assert_raises HasType::TypeMismatch do
      @sum.validate(1)
    end
  end

  def test_star_creates_product
    p = @sum * Integer
    assert p.is_a?(HasType::Product)
    assert_equal 2, p.arity
    assert p.validate([:a, 0])
    assert p.validate(['a', 0])
    assert_raises HasType::TypeMismatch do
      p.validate(['a', 1.0])
    end
  end

  def test_pipe_adds_to_sum
    s = @sum | Integer
    assert s.is_a?(HasType::Sum)
    assert s.validate(:a)
    assert s.validate('a')
    assert s.validate(1)
    assert_raises HasType::TypeMismatch do
      s.validate(1.0)
    end
  end

  def test_rocket_creates_hash
    h = @sum >> Integer
    assert h.is_a?(Hash)
    assert h.keys.include? @sum
  end

end
