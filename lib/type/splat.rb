module Glyde
  module HasType
    class Splat < Type

      # :: Type >> ()
      def initialize(t)
        @type = Type.make(t)
        @list = List.new(@type)
      end

      # May raise.
      # :: [a] >> self
      def validate(vs)
        @list.validate(vs)
        self
      rescue TypeMismatch => e
        e.type = self
        raise e
      end

      # :: () >> String
      def inspect
        "*#{@type.inspect}"
      end
    end

  end
end
