module Glyde
  module HasType
    #
    # Represents the LHS of a method signature.
    #
    # Important special case:
    # If the only required type (i.e. not optional, splat, or block)
    # provided to it (in ctor) is nil (i.e. (), nil, NilClass),
    # then treat it as an *empty* arg list.
    #
    class Product < Type

      # It's ok to have a Product wrap only a single Type.
      # We do this because the LHS of a signature -- which may
      # represent only 1 arg -- must always be a Product.
      #
      # :: Type * Type >> ()
      def initialize(t)
        @types = [Type.make(t)]
      end

      # :: () >> String
      def inspect
        @types.map {|t| t.inspect }.join(' * ')
      end

      # :: Type >> Product
      def *(t)
        @types << Type.make(t)
        self
      end

      # May raise.
      # :: [:any] >> self
      def validate(vals)
        unless vals.is_a?(Array)
          raise(ArgumentError, "Value #{vals.inspect} is not an Array.")
        end

        # Gather regular_types, @opts, and @splat.
        ts = types_without_opts_splat_and_block

        # Validate with each of those.
        validate_num_vals(ts, vals)
        val_idx = validate_regular_args(ts, vals)
        val_idx = validate_optional_args(vals, val_idx)
        validate_splat_args(vals, val_idx)
        self
      end

      # for testing
      # :: () >> Integer
      def arity
        @types.size
      end

      #--------
      private

      # The method itself will handle this, but the error msg
      # it provides may be confusing, so better to report the
      # problem ourselves?
      #
      # TURNED OFF!
      #
      # May raise.
      # :: [Type] * [a] >> ()
      def validate_num_vals(ts, vals)
        return
        if ts.size > vals.size
          raise(ArgumentError, "Too few arguments." +
                "  Expected number: #{ts.size}.  Actual number: #{vals.size}." +
                "\n  Expected type: #{ts.inspect}.")
        end
      end

      # Returns number of vals 'consumed'.
      # (Should it return the unused vals themselves?)
      #
      # May raise.
      # :: [Type] * [a] >> Integer
      def validate_regular_args(ts, vals)
        # REGULAR ARGS
        # Validate each in turn.  Remember how many vals consumed.
        idx = 0
        ts.zip(vals).each do |t,v|
          begin
            Type.validate(t,v)
          rescue TypeMismatch => e
            e.arg_idx = idx
            raise e
          end
          idx += 1
        end
        idx
      end

      # OPTS
      # Generally, in Ruby, this is how default args work:
      #   - If val not provided at all, uses the default.
      #   - If val provided but is nil, it uses nil.
      #
      # def foo(a, b=1)
      #   puts b
      # end
      #
      # >> foo(10)
      # => 1
      # >> foo(10, nil)
      # => nil
      #
      # :: [a] * Integer >> Integer
      def validate_optional_args(vals, val_idx)
        opt_vals = vals[val_idx, @opts.size]
        if opt_vals
          opt_vals.zip(@opts).each do |v,t|
            begin
              Type.validate(t,v)
            rescue TypeMismatch => e
              e.arg_idx = val_idx
              raise e
            end
            val_idx += 1
          end
        end
        val_idx
      end

      # :: [a] * Integer >> ()
      def validate_splat_args(vals, val_idx)
        if @splat
          unused_vals = vals[val_idx..-1]
          if unused_vals
            begin
              @splat.validate(unused_vals)
            rescue TypeMismatch => e
              e.arg_idx = val_idx
              raise e
            end
          end
        end
      end

      # :: () >> [Type]
      def types_without_opts_splat_and_block
        @twsab ||= calc_types_without_opts_splat_and_block
      end

      # May raise.
      # :: () >> [Type]
      def calc_types_without_opts_splat_and_block

        # Block
        types = @types.dup
        if types.last == Block
          types.pop
        end
        if types.any? {|t| t == Block }
          raise(Declaration::Error,
                "Signature may have Block only at end.")
        end

        # Splat
        @splat = types.last.is_a?(Splat) ? types.pop : nil
        if types.any? {|t| t.is_a? Splat }
          raise(Declaration::Error,
                "Splat may not follow non-Splat or non-Block.")
        end

        # Opts
        @opts = []
        while types.last.is_a?(Opt)
          @opts.unshift(types.pop)
        end
        if types.any? {|t| t.is_a? Opt }
          raise(Declaration::Error,
                "Opt may not be followed by regular arg.")
        end

        # -- Important Special Case --
        # If coder said this:  #  () >> ...
        # Then essentially there are NO arguments,
        # not one argument.
        if types == [NilClass]
          types = []
        end

        types
      end

    end
  end
end
