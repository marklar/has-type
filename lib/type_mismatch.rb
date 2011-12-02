module Glyde
  module HasType
    #
    # *Not* a subclass of StandardError -> not catch by accident.
    # Rescue and re-raise, adding info.
    #
    class TypeMismatch < Exception

      attr_accessor(:method,      # :: String    Full name.
                    :arg_idx,     # :: Integer   -1 if result.  0.. if argument.
                    :is_list,     # :: Bool      CURRENTLY UNUSED.
                    :app_caller)  # :: String    Call spot for 'broken' method.

      def initialize(t,v)
        @type, @value = t, v
        is_list = false
        arg_idx = nil
      end

      def type=(t)
        @type = t
      end

      def to_s
        "\n" +
          [ meth_str,
            app_caller_str,  # Add only if arg (not result) error?
            mismatch_str,
            expected_type_str,
            actual_val_str
          ].compact.join("\n") +
          "\n"
      end

      #-------
      private

      def app_caller_str
        "  Called from    :  #{app_caller}"
      end

      def expected_type_str
        "  Expected type  :  #{@type.inspect}"
      end

      def actual_val_str
        "  Actual value   :  #{@value.inspect}" + hash_str
      end

      def hash_str
        @value.is_a?(Hash) ? "  (one pair)" : ''
      end

      # If @type is List, then don't show entire list.
      # Show only the *part* of the list that doesn't match.

      def meth_str
        method     ? "  Method         :  #{method}"  : nil
      end

      def mismatch_str
        "  Mismatch of    :  " +
          ( case arg_idx
            when nil
              # raise RuntimeError, "Bug in HasType. arg_idx must not be nil."
              "Bug in HasType. arg_idx must not be nil."
            when -1
              'result'
            else
              "arg ##{arg_idx} (from 0)"
            end )
      end

    end
  end
end
