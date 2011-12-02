require 'test/unit'
dir = File.dirname(__FILE__)
require dir + '/../init'

class TestParser < Test::Unit::TestCase
  include Glyde

  def test_methods_present_only_in_block_def
    # BEFORE: NO
    should_be_absent

    # DURING: YES
    HasType::Parser.with_core_methods do
      for_each_cls_and_meth do |klass, method_name|
        assert class_method_defined?(klass, method_name)
      end
    end

    # AFTER: NO
    should_be_absent
  end

  def should_be_absent
    for_each_cls_and_meth do |klass, method_name|
      assert ! class_method_defined?(klass, method_name)
    end
  end


  #--- utils ---

  def class_method_defined?(klass, method_name)
    MethodMaker::ClassMethod.new(klass, method_name).
      send(:method_exists?)
  end

  def for_each_cls_and_meth
    HasType::Parser::CORE_TYPES.each do |klass|
      HasType::Parser::NAME_2_PROC.keys.each do |method_name|
        yield(klass, method_name)
      end
    end
  end

end
