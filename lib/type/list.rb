module Glyde
  module HasType
    #
    # Homogeneous.
    #
    class List < Type

      # :: Type >> ()
      def initialize(t)
        @type = Type.make(t)
      end

      def inspect
        '[' + @type.inspect + ']'
      end

      # May raise.
      # :: [a] >> self
      def validate(vals)
        unless vals.is_a?(Array)
          raise TypeMismatch.new(self, vals)
        end

        # Validate each member.
        # If any fails to type-check,
        # re-raise TypeMismatch on entire List.
        begin
          vals.each {|v| Type.validate(@type, v) }
        rescue TypeMismatch => e
          raise TypeMismatch.new(self, vals)        
        end
        self
      end

    end
  end
end
