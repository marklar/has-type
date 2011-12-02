require 'set'

module Glyde
  module HasType
    #
    # The Type Signature for a method.
    #
    # Create by providing it a Proc.
    #
    # When using the method to which it applies,
    # ask it whether its args & result type check.
    #
    # You may also ask a Signature whether its method has been used.
    #
    class Signature
      attr_reader :full_method_name

      # :: String * Symbol * Proc >> ()
      def initialize(class_name, method_name, proc=nil, &block)
        @full_method_name = calc_full_method_name(class_name, method_name)
        @recorder = Recorder.new
        @decl = Declaration.new(proc || block)
      end

      # :: [a] * b * String >> ()
      def record(args, res, from)
        @recorder.record(args, res, from)
      end

      # :: () >> String
      def inspect
        @decl.inspect
      end

      # :: () >> [String]
      def callers
        @recorder.callers
      end

      # :: () >> Bool
      def method_called?
        ! @recorder.empty?
      end

      # :: () >> String
      def actual_types
        @recorder.show
      end

      # May raise.
      # :: [a] * b >> ()
      def validate_args(args, app_caller=nil)
        @decl.lhs.validate(args)
      rescue TypeMismatch => e
        e.arg_idx ||= 0
        e.method = full_method_name
        e.app_caller = app_caller
        raise e
      end
          
      # May raise.
      # :: a >> self
      def validate_res_type(val, app_caller=nil)
        if @decl.rhs == NilClass
          self   # if RHS is (), do no validation.
        else
          begin
            Type.validate(@decl.rhs, val)
            self
          rescue TypeMismatch => e
            e.arg_idx = -1
            e.method = full_method_name
            e.app_caller = app_caller
            raise e
          end
        end
      end
      
      #--------
      private

      # String * Symbol >> String
      def calc_full_method_name(class_name, method_name)
        mn = method_name.to_s
        class_name + 
          (if mn =~ /^.*\.(.*)$/
             '.' + $1    # class method
           else
             '#' + mn    # instance method
           end)
      end
      
    end
  end
end
