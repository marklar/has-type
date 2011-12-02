module Glyde
  module MethodMaker
    class ClassMethod < Base
      private

      # :: Proc >> ()
      def mk_method(proc)
        @@n, @@p = @method_name, proc
        class << @klass
          define_method @@n, @@p
        end
        @@n = @@p = nil
      end

      # My raise NameError.
      # :: Symbol >> ()
      def rm_method(name)
        @@n = name
        class << @klass
          undef_method @@n
        end
        @@n = nil
      end

      # May raise NameError.
      # :: Symbol * Symbol >> ()
      def mk_alias(nu, old)
        @@nu, @@old = nu, old
        class << @klass
          alias_method @@nu, @@old
          ## send(:private, aka)
        end
      ensure
        @@nu = @@old = nil
      end

      # :: () >> String
      def full_name
        @full_name ||= "#{@klass}.#{@method_name}"
      end

      # Is there an existing method anywhere available,
      # either locally in this module or in ancestors?
      #
      # :: () >> Bool
      def method_exists?
        @@name = @method_name
        res = class << @klass
                [ 'public', 'protected', 'private'].any? do |level|
                  send(level + '_method_defined?', @@name)
                end
              end
        @@name = nil
        res
      end

    end
  end
end
