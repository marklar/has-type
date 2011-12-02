module Glyde
  module HasType
    class Sum < Type

      # :: Type * Type >> ()
      def initialize(t1, t2)
        validate_summable_parts(t1, t2)
        @types = [Type.make(t1), Type.make(t2)]
      end

      # :: () >> String
      def inspect
        '(' + @types.map {|t| t.inspect }.join('|') + ')'
      end

      # :: Type >> Sum
      def |(t)
        @types.push(Type.make(t))
        self
      end

      # May raise.
      # :: a >> self
      def validate(val)
        unless validates?(val)
          raise TypeMismatch.new(self, val)
        end
        self
      end

      #-------
      private

      # May raise.
      # :: Type * Type >> ()
      def validate_summable_parts(t1, t2)
        [t1, t2].each do |t|
          not_Object(t) || not_a_symbol(t)
        end
      end

      # May raise.
      # :: Type >> ()
      def not_Object(t)
        if t == Object
          raise(Declaration::Error,
                "May not use 'Object' in a Sum type declaration.")
        end
      end

      # May raise.
      # :: Type >> ()
      def not_a_symbol(t)
        if t.is_a?(Symbol)
          raise(Declaration::Error, "May not use a Symbol " +
                "(#{t.inspect}) in a Sum type declaration.")
        end
      end

      # Does val match *any* of the @types?
      # :: a >> Bool
      def validates?(val)
        @types.any? do |t|
          begin
            Type.validate(t,val)
            true
          rescue TypeMismatch => e
            false
          end
        end
      end

    end
  end
end
