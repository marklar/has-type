module Glyde
  module MethodMaker
    class InstanceMethod < Base
      private

      # :: Proc >> ()
      def mk_method(proc)
        @klass.send(:define_method, @method_name, proc)
      end

      # May raise NameError.
      # ::  Symbol >> ()
      def rm_method(name)
        @klass.send(:undef_method, name)
      end

      # May raise NameError.
      # :: Symbol * Symbol >> ()
      def mk_alias(nu, old)
        @klass.send(:alias_method, nu, old)
        ## @klass.send(:private, @aka)
      end

      # :: () >> String
      def full_name
        @full_name ||= "#{@klass}##{@method_name}"
      end

      # Is there an existing method anywhere available,
      # either locally in this module or in ancestors?
      #
      # :: () >> Bool
      def method_exists?
        [ 'public', 'protected', 'private'].any? do |level|
          @klass.send(level + '_method_defined?', @method_name)
        end
      end

    end
  end
end
