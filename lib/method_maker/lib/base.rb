module Glyde
  module MethodMaker
    #
    # Abstract.
    #
    class Base

      # :: Class * Symbol >> ()
      def initialize(klass, method_name)
        @klass = klass
        @method_name = method_name
        @aka = get_aka(method_name)
      end

      # But if it does exist, create a wrapper around it which
      # first executes the before_proc, then calls the original,
      # then executes the after_proc.
      #
      # May raise.
      # :: Proc * Proc >> ()
      def wrap(before_proc, after_proc)
        unless method_exists?  # Anywhere, including in ancestors.
          raise(RuntimeError,
                "Method #{full_name} not defined; cannot be wrapped.")
        end
        p = wrapper_proc(@aka, before_proc, after_proc)
        create(p)
      end

      # Meant for TEMPORARY changes.
      # Create a new method which does NOT wrap any existing one.
      # Simply move any existing one "aside", so that it can be
      # reconstituted later.  Then define new one in its place.
      #
      # :: Class * Symbol * Proc >> ()
      # :: (Proc|nil) * Block >> ()
      def create(proc=nil, &block)
        # There may or may not be an existing method of this name.
        # Difficult to check for that: because we don't want to know whether
        # it is defined in this module OR ITS ANCESTORS, but rather
        # whether it's actually defined *here*.
        # So we cannot use #(private_|protected_|public_|^)method_defined?
        # Instead, we simply rescue from any NameError that should
        # arise from trying to alias a non-existent method definition.
        mk_alias(@aka, @method_name)
      rescue NameError
        # No-op.  Catch and ignore NameError.
      ensure
        mk_method(proc || block)
      end

      # Undefines named method, reconstituting old version.
      # (If it had replaced any method temporarily
      # via either #wrap OR #create, reconstitute it.)
      #
      # :: () >> ()
      def destroy
        # Maybe there was a pre-existing impl, now known as 'aka'.
        # It's difficult to check whether 'aka' is defined (in *this* module)
        # or not, so we won't bother checking directly, and instead simply
        # attempt to deal with it.  If doing so fails, we'll get a NameError.
        #
        # If an 'aka' exists:
        #   + alias it back into place, overwriting monkey-patched version, and
        #   + remove its alias.
        mk_alias(@method_name, @aka)
        rm_method(@aka)
      rescue NameError
        # If an 'aka' does NOT exist:
        #   + simply remove the new definition.
        rm_method(@method_name)
      end

      #--------
      private
      #--------

      # :: Symbol * Proc * Proc >> Proc
      def wrapper_proc(aka, before_proc, after_proc)
        lambda do |*args, &block|
          before_proc.call(*args) if before_proc
          res = send(aka, *args, &block)
          after_proc.call(res, *args) if after_proc
          res
        end
      end

      # Method names may end with non-alphanums: %w(! ? =)
      # If present, make sure to move to end of alias.
      #
      # :: Symbol >> Symbol
      def get_aka(meth_name)
        str = meth_name.to_s
        last_ch = str[-1].chr
        if ['=', '!', '?'].include?(last_ch)
          str[0..-2] + ALIAS_SUFFIX + last_ch
        else
          meth_name.to_s + ALIAS_SUFFIX
        end.to_sym
      end

    end
  end
end
