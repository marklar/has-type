module Glyde
  module HasType
    class Opt < Type

      def initialize(t)
        @type = Type.make(t)
      end

      def validate(v)
        Type.validate(@type,v)
      rescue TypeMismatch => e
        e.type = self
        raise e
      end

      def inspect
        "Opt(#{@type.inspect})"
      end
    end

  end
end
