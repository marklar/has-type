module Glyde
  module MethodMaker
    
    # Arbitrary, improbable.
    ALIAS_SUFFIX = '_MM_ALIASED'
    
    # Factory.
    # :: Class * Symbol >> MethodMaker::Base (subclass)
    def self.for_method(klass, meth_name)
      if cls_meth_name = get_class_method_name(meth_name)
        ClassMethod.new(klass, cls_meth_name)
      else
        InstanceMethod.new(klass, meth_name)
      end
    end

    # :: Symbol >> Bool
    def self.alias?(method_name)
      method_name.to_s =~ /#{ALIAS_SUFFIX}.?$/
    end

    # :: Symbol >> String
    def self.original_name(method_name)
      method_name.sub(ALIAS_SUFFIX, '')
    end

    #--------
    private

    # If method is a *class* method,
    # it should be :"self.foo" or :"MyClass.foo".
    #
    # :: Symbol >> (Symbol|nil)
    def self.get_class_method_name(meth_name)
      (meth_name.to_s =~ /^.*\.(.*)$/) ? $1.to_sym : nil
    end
    
  end
end
