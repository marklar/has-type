module Glyde
  module HasType
    #
    # Abstract.
    #
    class Type

      # May raise.
      # :: Type * :a >> Bool
      def self.validate(t,v)
        case
        when t.is_a?(Type)
          t.validate(v)
        when t == Bool
          [TrueClass, FalseClass].any? {|c| v.is_a? c } ||
            raise(TypeMismatch.new(t,v))
        when t.is_a?(NilClass)
          # True only for ARGS, not results.
          (v == []) || raise(TypeMismatch.new(t,v))
        when t.is_a?(Class) && t < UserType
          # For user-declared types (type :MyType do ... end).
          t.validate(v)
        else
          v.is_a?(t) || raise(TypeMismatch.new(t,v))
        end
        true
      end
      
      # May raise.
      # :: Class >> Type   ??
      def self.make(value)
        case value
        when NilClass                then NilClass
        when TrueClass, FalseClass   then Bool
        when Class, Type             then value
        when Symbol    #                  then Object
          Variable.new(value)
        when Hash
          # exactly 1 k:v pair
          # FixMe: add support for multiple!
          k,v = [value.keys.first, value.values.first]
          HashMap.new(make(k), make(v))
        when Array
          case value.size
          when 1
            List.new(make(value.first))
          else
            raise(Declaration::Error,
                  "Array may contain only one type: #{value.inspect}.")
          end
        else
          raise(Declaration::Error, "What is it?: #{value.inspect}")
        end
      end

      #--------------
      #-- Instance --
      #--------------

      def validate(v)
        raise RuntimeError, "--ABSTRACT--"
      end

      # :: Type >> Splat
      def splat
        Splat.new(self)
      end

      # :: Type >> Opt
      def opt
        Opt.new(self)
      end
      
      # ToDo: Make this Hash a Function(Type)?
      # :: Type >> Hash
      def >>(t)
        { self => Type.make(t) }
      end

      #-- Override in subs --

      # :: Type >> Product
      def *(t)
        Product.new(self) * t
      end

      # :: Type >> Sum
      def |(t)
        Sum.new(self, t)
      end

    end
  end
end
