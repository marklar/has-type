dir = File.dirname(__FILE__)
require dir + '/../init'

class Bobo
  include Glyde::HasType

  #
  # N.B.  Type variable.  Values' types must be same OR
  # share an ancestor more specific than Object.
  #
  type :OtherHash do {Symbol=>String} end
  sig do :a * OtherHash >> :a * OtherHash end
  def self.class_method(a, h={})
    puts "in class_method"
    [a, h]
  end

  # - instance -

  sig_attr_accessor :my_int do Integer end

  def initialize
    self.my_int = 1
  end

  sig do [Integer] >> String end
  def takes_int_array(ints)
    ints.join(',')
  end

  # For making type synonyms.
  type :MyKey  do String |Symbol   end
  type :MyVal  do Integer|String   end
  type :MyHash do {MyKey => MyVal} end

  sig do MyKey * MyVal * MyHash >> MyHash end
  def add_to_hash(k, v, hash)
    hash[k] = v
    hash
  end

  sig do Integer * :a.splat >> OtherHash end
  def foo(int, *args)
    puts my_int
    {:args => args.inspect}
  end

  sig do (Integer|nil) >> () end
  def bar(a)
    puts 'in bar'
    puts a
  end

end


class A
  def all

    b = Bobo.new
    b.bar(1)

    puts b.takes_int_array([1,2,3])
    # puts b.takes_int_array([-2,-1,0,1,2,:three,4,5,6,7,8,9])

    # h = {'a' => 1, 'b' => 2.3}
    h = {'a' => 1, 'b' => 2}
    puts b.add_to_hash('c', 3, h).inspect

    puts Bobo.class_method(1, {:a => 'foo'}).inspect
    b = Bobo.new
    puts b.foo(3, 'foo', :foo, 'bar').inspect

    b.bar(nil)


    puts
    puts
    puts "Bobo's CALLED signed methods: "
    puts Bobo.called_signed_methods.inspect
    puts Bobo.uncalled_signed_methods.inspect

    puts
    puts "actual types: "
    puts Glyde::HasType.actual_types

    puts
    puts "callers: "
    puts Glyde::HasType.callers

  end
end

Glyde::HasType.turn_off
a = A.new
a.all

Glyde::HasType.turn_on
a = A.new
a.all


