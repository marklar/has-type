module Glyde
  module HasType
    class Declaration

      class Error < Exception; end

      #--- INSTANCE ---

      def initialize(proc=nil, &block)
        @proc = proc || block
      end

      def inspect
        lhs.inspect + ' >> ' + rhs.inspect
      end

      # :: () >> Type
      def lhs
        @lhs || (calc_types ; @lhs)
      end

      # :: () >> Type
      def rhs
        @rhs || (calc_types ; @rhs)
      end
      
      #--------
      private

      # Sets ivars.
      # :: () >> ()
      def calc_types
        sig_hash = Parser.parse { @proc.call }
        unless sig_hash.is_a?(Hash)
          raise(Error, "Signature declaration (#{sig_hash.inspect}) " +
                "must be a Hash.")
        end
        # Exactly one k:v pair in hash.
        sig_hash.each do |lhs, rhs|
          @lhs, @rhs = make_product(lhs), rhs
        end
      end

      # EVERY LHS IS A PRODUCT.
      # IF IT ISN'T ALREADY ONE, MAKE IT ONE.
      # :: Type >> Product
      def make_product(lhs)
        lhs.is_a?(Product) ? lhs : Product.new(lhs)
      end

    end
  end
end
