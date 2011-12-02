require 'test/unit'
dir = File.dirname(__FILE__)
require "./#{dir}/../init"

class TestMethodMaker < Test::Unit::TestCase
  include Glyde
  
  class Foo
    def self.existing_class_method(str)
      'original class method'
      str
    end
    def existing_instance_method(int)
      'original instance method'
      int
    end
  end
  
  def setup
    @foo = Foo.new
    @before_proc = lambda {|*args| raise(StandardError,'in before') }
    @after_proc  = lambda {|res, *args| raise(StandardError, 'in after') }
  end
  
  def teardown
  end
  
  # -- too internal? --
  def test_get_class_method_name
    assert_equal nil,  MethodMaker.get_class_method_name(:foo)
    assert_equal :foo, MethodMaker.get_class_method_name(:'self.foo')
  end
  
  def test_wrap_missing_method_raises
    assert_raises RuntimeError do
      MethodMaker.for_method(Foo, :nada).
        wrap(@before_proc, @after_proc)
    end
    assert_raises RuntimeError do
      MethodMaker.for_method(Foo, :'self.nada').
        wrap(@before_proc, @after_proc)
    end
  end
  
  def test_wrap_existing_instance_method
    assert_equal 1, @foo.existing_instance_method(1)
    mm = MethodMaker.for_method(Foo, :existing_instance_method)
    mm.wrap(nil, nil)
    assert_equal 1, @foo.existing_instance_method(1)
    mm.destroy()
    assert_equal 1, @foo.existing_instance_method(1)
    
    mm.wrap(@before_proc, nil)
    assert_raises StandardError do
      @foo.existing_instance_method(1)
    end
    mm.destroy()
    assert_equal 1, @foo.existing_instance_method(1)
    
    mm.wrap(nil, @after_proc)
    assert_raises StandardError do
      @foo.existing_instance_method(1)
    end
    mm.destroy()
    assert_equal 1, @foo.existing_instance_method(1)
  end
  
  def test_wrap_existing_class_method
    s = 'foo'
    m = :'self.existing_class_method'
    assert_equal s, Foo.existing_class_method(s)
    mm = MethodMaker.for_method(Foo, m)
    mm.wrap(nil, nil)
    assert_equal s, Foo.existing_class_method(s)
    mm.destroy()
    assert_equal s, Foo.existing_class_method(s)
    
    mm.wrap(@before_proc, nil)
    assert_raises StandardError do
      Foo.existing_class_method(s)
    end
    mm.destroy()
    assert_equal s, Foo.existing_class_method(s)
    
    mm.wrap(nil, @after_proc)
    assert_raises StandardError do
      Foo.existing_class_method(s)
    end
    mm.destroy()
    assert_equal s, Foo.existing_class_method(s)
  end
  
  def test_non_existing_instance_method
    assert_raises NoMethodError do
      @foo.new_instance_method
    end
    mm = MethodMaker.for_method(Foo, :new_instance_method)
    mm.create() { 'foo' }
    assert_equal 'foo', @foo.new_instance_method
    mm.destroy()
    assert_raises NoMethodError do
      @foo.new_instance_method
    end
  end
  
  def test_non_existing_class_method
    assert_raises NoMethodError do
      Foo.new_class_method
    end
    mm = MethodMaker.for_method(Foo, :'self.new_class_method')
    mm.create() { 'bar' }
    assert_equal 'bar', Foo.new_class_method
    mm.destroy()
    assert_raises NoMethodError do
      Foo.new_class_method
    end
  end

  def test_existing_instance_method
    assert_equal 1, @foo.existing_instance_method(1)
    mm = MethodMaker.for_method(Foo, :existing_instance_method)
    mm.create() { 'bar' }
    assert_equal 'bar', @foo.existing_instance_method
    mm.destroy()
    assert_equal 1, @foo.existing_instance_method(1)
  end

  def test_existing_class_method
    assert_equal 'foo', Foo.existing_class_method('foo')
    mm = MethodMaker.for_method(Foo, :'self.existing_class_method')
    mm.create() { 'bar' }
    assert_equal 'bar', Foo.existing_class_method
    mm.destroy()
    assert_equal 'foo', Foo.existing_class_method('foo')
  end

end
