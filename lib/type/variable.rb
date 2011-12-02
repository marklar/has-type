module Glyde
  module HasType
    #
    # If two type variables are different (:a, :b),
    # their corresponding values may be of the same type
    # or different.
    # 
    # If they're the *same* type variable,
    # then their values' types must match:
    # Values' types must:
    #   a: be the same -OR-
    #   b: share an ancestor more specific than Object.
    #
    # Perhaps we need another model: TypeBinding.
    #
    class Variable < Type

      # :: Symbol >> ()
      def initialize(name)
        @name = name
      end

      # May raise.
      # :: a >> self
      def validate(val)
        self
      end

    end
  end
end
