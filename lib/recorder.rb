module Glyde
  module HasType
    class Recorder

      # :: () >> ()
      def initialize
        @types   = Set.new []
        @callers = Set.new []
      end

      # :: [a] * b * String >> ()
      def record(args, res, from)
        record_types(args, res)
        add_caller(from)
      end

      # :: () >> Bool
      def empty?
        @types.empty?
      end

      # :: () >> String
      def callers
        @callers.to_a.sort
      end

      # SHOW CALLERS?
      # :: () >> String
      def show
        @types.to_a.sort
      end

      #--------
      private
      #--------

      # :: String >> ()
      def add_caller(c)
        @callers << c
      end

      # :: [a] * b >> ()
      def record_types(args, res)
        str = (arg_classes_str(args) +
               " >> " +
               display_name(res))
        @types << str
      end

      # :: [a] >> String
      def arg_classes_str(args)
        if args.empty?
          '()'
        else
          args.map {|a| display_name(a) }.join(" * ")
        end
      end

      # :: a >> String
      def display_name(v)
        case v
        when TrueClass, FalseClass
          'Bool'
        when NilClass
          '()'
        when Hash
          hash_map_display_name(v)
        when Array
          list_display_name(v)
        else
          v.class.name
        end
      end

      # :: Hash >> String
      def hash_map_display_name(val_hash)
        key_opts_str = opts_str_for(val_hash.keys)
        val_opts_str = opts_str_for(val_hash.values)
        '{' + key_opts_str + ' => ' + val_opts_str + '}'
      end

      # :: [Type] >> String
      def list_display_name(val_ary)
        '[' + opts_str_for(val_ary) + ']'
      end

      # :: [a] >> String
      def opts_str_for(val_ary)
        val_ary.
          map {|v| display_name(v) }.
          uniq.sort.join('|')
      end

    end
  end
end
