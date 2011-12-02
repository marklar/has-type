require 'test/unit'
dir = File.dirname(__FILE__)
require dir + '/../init'

class TestSignature < Test::Unit::TestCase
  include Glyde

  class Foo; end

  def setup
    HasType::Parser.send(:def_core_methods)
  end

  def teardown
    HasType::Parser.send(:undef_core_methods)
  end

  def test_optional
    s = HasType::Signature.new('Foo', :bar) do
      String * String * Integer.opt *
        Float.opt * String.splat >> String
    end
    assert s.validate_args(['a', 'b'])
    assert s.validate_args(['a', 'b', 1])
    assert s.validate_args(['a', 'b', 1, 1.2])
    assert s.validate_args(['a', 'b', 1, 1.2, 'foo', 'bar', 'baz'])
    assert_raises HasType::TypeMismatch do
      s.validate_args(['a', 'b', 1, nil])
    end
  end

  def test_bobo
    s = HasType::Signature.new('Foo', :bar) do
      [Symbol|String] >> String
    end
    assert s.validate_args([[:ting, 'mai', :kai]])
    assert s.validate_res_type('foo')
  end

  def test_sum
    s = HasType::Signature.new('Foo', :bar) do (Symbol|nil) >> () end
    assert s.validate_args([:foo])
  end

  def test_nil_sum
    s = HasType::Signature.new('Foo', :bar) do [Symbol|nil] >> () end
    assert s.validate_args([[:ting, ()]])
    s = HasType::Signature.new('Foo', :bar) do [Symbol|NilClass] >> () end
    assert s.validate_args([[:ting, ()]])
    s = HasType::Signature.new('Foo', :bar) do [Symbol|()] >> () end
    assert s.validate_args([[:ting, ()]])
    assert s.validate_res_type('any value at all')
    s = HasType::Signature.new('Foo', :bar) do [nil|Symbol] >> () end
    assert s.validate_args([[:ting, ()]])
  end

  def test_blurfl
    s = HasType::Signature.new('Foo', :bar) do
      Float * ({Symbol => Integer}|{String => Float}) >> ()
    end
    assert s.validate_args([1.2, {:foo => 1,    :bar  => 2}])
    assert s.validate_args([1.2, {'foo' => 1.1, 'bar' => 2.1}])
    assert_raises HasType::TypeMismatch do
      s.validate_args([1.2, {'foo' => 1.1, :bar => 2.1}])
    end
    assert_raises HasType::TypeMismatch do
      s.validate_args([1.2, {'foo' => 1.1, 'bar' => 2}])
    end
    s.validate_res_type(nil)
    s.validate_res_type(100)
  end

  def test_foo
    s = HasType::Signature.new('Foo', :bar) do
      Float * (Integer|Float) * Integer >> Float
    end
    assert s.is_a?(HasType::Signature)
    assert !s.method_called?
    assert_equal [], s.actual_types
    s.validate_args([1.2, 1, 1])
    s.validate_res_type(1.2)
    assert_raises HasType::TypeMismatch do
      s.validate_res_type('foo')
    end
  end

  def test_bar
    s = HasType::Signature.new('Foo', :baz) do
      Float * ({Symbol => Integer}|{String => Float}) >> ()
    end
    assert s.is_a?(HasType::Signature)
    # assert s.lhs.is_a?(HasType::Product)
    # assert_equal NilClass, s.rhs
    assert s.validate_args([1.1, {:a => 1}])
  end

end
