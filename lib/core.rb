module Kernel

  # :: Symbol|String * Block >> Class
  def define_class(name, super_class=Object, &blk)
    # 'self' -- the class from which define_class is called.
    self.const_set(name, Class.new(super_class, &blk))
  end

  # :: Symbol|String >> Class
  def get_class(name)
    # 'self' -- the class from which get_class is called.
    self.const_get(name)
  end

end
