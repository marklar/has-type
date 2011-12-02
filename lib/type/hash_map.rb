module Glyde
  module HasType
    class HashMap < Type

      # :: Type * Type >> ()
      def initialize(t1,t2)
        @key = Type.make(t1)
        @val = Type.make(t2)
      end

      def inspect
        '{' + @key.inspect + ' => ' + @val.inspect + '}'
      end

      # May raise.
      # :: a >> self
      def validate(val)
        unless val.is_a?(Hash)
          raise TypeMismatch.new(self, val)
        end
        
        # Validate each k:v pair.
        # If any fails to type-check,
        # re-raise TypeMismatch on that pair (qua mini-Hash).
        val.each do |k,v|
          begin
            Type.validate(@key,k) && Type.validate(@val,v)
          rescue TypeMismatch => e
            raise TypeMismatch.new(self, {k => v})
          end
        end
        self
      end

    end
  end
end
