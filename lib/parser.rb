module Glyde
  module HasType
    class Parser

      # :: Block >> a
      def self.parse(&block)
        with_core_methods(&block)
      end

      #--------
      private

      # :: Block >> a
      def self.with_core_methods
        def_core_methods
        res = yield
        undef_core_methods
        res
      end

      # THESE CONSTANTS USED IN UNIT TESTS.
      CORE_TYPES = [Class, Array, Hash, NilClass, Symbol]

      NAME_2_PROC =
        { :*      =>  lambda {|t|  Product.new(self) * t             },
          :|      =>  lambda {|t|  Sum.new(self, t)                  },
          :>>     =>  lambda {|t|  {Type.make(self) => Type.make(t)} },
          :splat  =>  lambda {     Splat.new(self)                   },
          :opt    =>  lambda {     Opt.new(self)                     }
        }

      # Adds INSTANCE methods to these classes.
      def self.def_core_methods
        # 'self': FREE variable.
        # NOT Signature instance, but rather will be
        # the instance of the class upon which def is added.
        NAME_2_PROC.each do |sym,proc|
          CORE_TYPES.each do |t|
            MethodMaker.for_method(t, sym).create(proc)
          end
        end
      end

      def self.undef_core_methods
        NAME_2_PROC.keys.each do |method|
          CORE_TYPES.each do |t|
            MethodMaker.for_method(t, method).destroy
          end
        end
      end

    end
  end
end
