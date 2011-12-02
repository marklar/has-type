module Glyde
  module HasType

    class UserType; end

    #
    # For mixed-into class
    #
    module ClassMethods

      SIG_ALIASES = [:i, :ii, :i!]

      # :: Symbol >> String
      def has_type_inspect(method_name)
        sig = class_variable_get(:@@sigs)[self][method_name]
        "signature: #{sig.inspect}\n" +
          "actual_types: #{sig.actual_types}\n" +
          "callers: #{sig.callers}\n"
      end

      # :: () >> [String]
      def called_signed_methods
        HasType.method_names_where(self) {|sig| sig.method_called? }
      end

      # :: () >> [String]
      def uncalled_signed_methods
        HasType.method_names_where(self) {|sig| ! sig.method_called? }
      end

      # :: () >> [String]
      def all_signed_methods
        HasType.method_names_where(self) {|_| true }
      end

      # Define a new class (in local namespace),
      # and give it Signature::Type behavior.
      #   type :MyHash do {String|Symbol => [Integer]} end
      # Useful for re-using and composing sig types.
      #
      # :: (Symbol|String) * (Proc|nil) * Block >> ()
      def type(type_name, sig_proc=nil, &block)
        module_eval do
          define_class(type_name, UserType) do
            
            class_variable_set(:@@proc, sig_proc || block)
            # @@proc = sig_proc || block
            
            def self.validate(v)
              Type.validate(inner_type, v)
            end
            
            def self.inner_type
              if class_variable_defined?(:@@inner_type)
                class_variable_get(:@@inner_type)
              else
                t = Parser.parse { class_variable_get(:@@proc).call }
                class_variable_set(:@@inner_type, Type.make(t))
              end
            end
            
            def self.inspect
              inner_type.inspect + ':' + self.name
            end
          end
        end
      end

      # Creates Signature.  Stores in class var.
      # Does not analyze the sig-proc in any way.
      #
      # :: Block >> ()
      def sig(&block)
        HasType.set_last_proc(self, block)
      end
      SIG_ALIASES.each {|a| alias_method a, :sig }

      # :: Symbol.splat * Block >> ()
      def sig_attr_accessor(*attr_names, &block)
        sig_attr_reader(*attr_names, &block)
        sig_attr_writer(*attr_names, &block)
      end

      # :: Symbol.splat * Block >> ()
      def sig_attr_reader(*attr_names, &block)
        if !block
          attr_reader *attr_names
        else
          p = lambda { () >> block.call }
          attr_names.each do |a|
            HasType.set_last_proc(self, p)
            attr_reader a
          end
        end
      end

      # :: Symbol.splat * Block >> ()
      def sig_attr_writer(*attr_names, &block)
        if !block
          attr_writer *attr_names
        else
          p = lambda { side = block.call;  side >> side }
          attr_names.each do |a|
            HasType.set_last_proc(self, p)
            attr_writer a
          end
        end
      end

    end
  end
end
