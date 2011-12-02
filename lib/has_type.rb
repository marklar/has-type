module Glyde
  module HasType
    @@on = true
    @@sigs ||= {}     # :: { Class => {method_name_Sym => Signature} }
    @@last_sig_proc ||= {}   # :: { Class => Proc }

    #
    # This all lives in the TOP LEVEL of the Glyde::HasType namespace
    # for ease of include-ing in other classes.
    #
    # There are other modules and classes which live in this
    # namespace besides, of course.
    #

    # :: Class >> ()
    def self.included(klass)
      create_class_vars(klass)
      add_method_added_callbacks(klass)
      klass.extend(ClassMethods)
    end

    # :: () >> Bool
    def self.on?
      @@on
    end

    # :: () >> ()
    def self.turn_on
      if !on?
        @@sigs.keys.each {|c| create_all_wrapper_methods(c) }
        @@on = true
      end
    end

    # :: () >> ()
    def self.turn_off
      if on?
        # Does NOT clear caches of data inside Signatures.
        @@sigs.keys.each {|c| destroy_all_wrapper_methods(c) }
        @@on = false
      end
    end

    # :: () >> [String]
    def self.called_methods
      method_names_for_sigs_where do |sig|
        sig.method_called?
      end
    end

    # :: () >> [String]
    def self.uncalled_methods
      method_names_for_sigs_where do |sig|
        ! sig.method_called?
      end
    end

    # :: () >> String
    def self.actual_types
      show_sigs(:actual_types)
    end

    # :: () >> String
    def self.callers
      show_sigs(:callers)
    end

    #--------
    private
    #--------

    # :: Symbol >> String
    def self.show_sigs(sig_method_name)
      @@sigs.map do |_, meth_2_sig|   # for each HasType-d class
        meth_2_sig.map do |_,sig|
          strs = sig.send(sig_method_name)
          ( "#{sig.full_method_name}\n" +
            indented_strs(strs, 3) )
        end.join("\n")
      end.join("\n")
    end

    # :: [String] >> String
    def self.indented_strs(strs, n)
      strs.map {|s| (' ' * n) + s }.join("\n")
    end

    # Add class vars to HasType,
    # accessible in mixed-into classes via class_variable_{get|set}.
    #
    # :: Class >> ()
    def self.create_class_vars(klass)
      @@sigs[klass] = {}
      @@last_sig_proc[klass] = nil
    end

    # Safely (i.e. without clobbering existing versions)
    # adds methods into mixed-into class:
    #    - self.method_added
    #    - self.singleton_method_added
    #
    # When a user defines his own methods,
    # allows one to define a wrapper around it.
    #
    # :: Class >> ()
    def self.add_method_added_callbacks(klass)
      mm = MethodMaker.for_method(klass, :'self.singleton_method_added')
      mm.create do |method_name|
        method_added( "self.#{method_name}".to_sym )
      end

      # For any method:
      #
      #   * Has _associated_ Signature?
      #     -> Already defining a wrapper method.  Do nothing.
      #
      #   * Is itself an alias?
      #     -> Don't wrap it.
      #
      #   * Is novel && !alias && coder defined Signature?
      #     -> Apply Signature to the method.
      # 
      mm = MethodMaker.for_method(klass, :'self.method_added')
      mm.create do |method_name|
        unless @@sigs[klass][method_name] || MethodMaker.alias?(method_name)
          # If no proc, coder defined no sig.
          if proc = @@last_sig_proc[klass]
            sig = HasType.create_sig(klass, method_name, proc)
            HasType.set_last_proc(klass, nil)
            if @@on
              HasType.create_one_wrapper_method(klass, method_name, sig)
            end
          end
        end
      end
    end

    # :: Class >> ()
    def self.create_all_wrapper_methods(klass)
      @@sigs[klass].each do |method_name, sig|
        create_one_wrapper_method(klass, method_name, sig)
      end
    end
    
    # :: Class * Symbol * Signature >> ()
    def self.create_one_wrapper_method(klass, method_name, sig)
      # Create 'call_site' here so can
      #   - set value just once in first proc, and
      #   - re-use in second proc.
      call_site = nil
      before_proc = lambda do |*args|
        # caller: method call, so happens when proc is called,
        # not during self.create_one_wrapper_method.
        call_site = most_recent_app_caller(caller)
        sig.validate_args(args, call_site)
      end
      after_proc = lambda do |res, *args|
        sig.validate_res_type(res, call_site)
        sig.record(args, res, call_site)
      end
      MethodMaker.for_method(klass, method_name).
        wrap(before_proc, after_proc)
    end

    MTHD_MKR_RE = /\/method_maker\//
    # Assumes that MethodMaker code will have 'method_maker'
    # as part of its path.  Good assumption?
    #
    # :: [String] >> String
    def self.most_recent_app_caller(caller_list)
      c = caller_list.detect {|s| s !~ MTHD_MKR_RE }  # ignore internals
      MethodMaker.original_name(c)
    end
    
    # :: () >> ()
    def self.destroy_all_wrapper_methods(klass)
      @@sigs[klass].each do |method_name, _|
        MethodMaker.for_method(klass, method_name).destroy
      end
    end

    # Remember that we have this signature, so that:
    #   - creating the wrapper method won't induce
    #     creating another wrapper method around *it*
    #   - we know which methods have sigs,
    #     so we can turn them on and off.
    #
    # :: Symbol * Proc >> Signature
    def self.create_sig(klass, method_name, proc)
      sig = Signature.new(klass.name, method_name, proc)
      @@sigs[klass][method_name] = sig
      sig
    end

    # :: Block >> [String]
    def self.method_names_for_sigs_where
      @@sigs.map do |_, meth_2_sig|   # for each HasType-d class
        meth_2_sig.
          select {|_,sig| yield sig }.        # only predicate-matching sigs
          map {|_,sig| sig.full_method_name } # their names
      end
    end

    # :: Proc >> ()
    def self.set_last_proc(klass, proc=nil, &block)
      @@last_sig_proc[klass] = proc || block
    end

    # Called from ClassMethods.
    # :: Class * Block >> [String]
    def self.method_names_where(klass)
      name2sig = @@sigs[klass]
      pairs_matching_predicate = name2sig.select {|_,sig| yield sig }
      syms = pairs_matching_predicate.map {|name,_| name }
      syms.map {|sym| sym.to_s }.sort
    end

  end
end
