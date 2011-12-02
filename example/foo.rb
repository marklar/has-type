dir = File.dirname(__FILE__)
require dir + '/../init'

#
# defaults?
# in prod, having test code
# more valuable than comments?
# what gain at runtime from this?
#

class Foo
  include Glyde::HasType

  sig do [Symbol|String] >> String end
  def ting(parts)
    parts.join(" ")
  end

  sig do Bar >> Bar end
  def self.blurfl(bar)
    bar
  end

  #
  # splat: call w/ different binding.
  #
  sig do Integer * (Integer|Float).splat >> Integer end
  def splatted(int, *others)
    puts "size of 'others': #{others.size}."
    others.size
  end

  sig do Integer * Object >> Integer end
  def blurfl(int, anything)
    puts int.inspect
    puts anything.inspect
    int
  end

  sig do [Blurfl] >> () end
  def bojack(args)
    puts args[0].inspect
  end

  sig do () >> () end
  def bar
    puts 'baz'
  end

  # type :MyHash do {Symbol => [Integer|Float]} end
  # sig do Float * Class::MyHash >> () end

  sig do Float * {Symbol => [Integer|Float]} >> () end
  def hashmash(f,h)
    puts 'in hashmash'
  end

  sig do Float * ({Symbol => Integer}|{String => Float}) >> () end
  def hashish(f,h)
    puts 'in hashish'
  end

  sig do
    (Integer|String) *          # name
    [Integer] *                 # ids
    (Numeric|String|nil) >>     # something
    (Bool|nil)                  # foo?
  end
  def foo(a,b,c)
    puts a.inspect
    puts b.inspect
    puts c.inspect
  end

  MyStruct = Struct.new(:id, :other_id)
  sig do Integer * Integer >> MyStruct end
  def tuplize(a,b)
    MyStruct.new(a,b)
  end

  sig do Integer * Proc * Proc * Block >> Integer end
  def blocked(int, proc1, proc2)
    if block_given?
      puts 'yielding...'
      yield
    else
      puts 'NO block'
    end
    int
  end
end

class Bar
  include Glyde::HasType

  # sig :'self.bar', o{ String * [Integer] >> Integer }
  sig do String * [Integer] >> Integer end
  def self.bar(str, ints)
    ints.first
  end

  sig do Integer >> Integer end
  def xIEJIEJIE(i)
    i
  end

  sig do Foo >> Foo end
  def ting(foo)
    foo
  end
end

Glyde::HasType.turn_on

f = Foo.new
b = Bar.new

puts Foo.blurfl(b)
puts f.blurfl(1, 'a')
puts Bar.bar('str', [1,2,3])

puts b.ting(f).inspect
puts b.xIEJIEJIE(3)

p1 = lambda {|x| x}
p2 = lambda {|y| y}
# f.blocked(1, p1, p2) {puts 'IN block'}
f.blocked(1, p1, p2)

# o{ Float * ({Symbol => Integer}|{String => Float}) >> () }
f.hashish(2.1, {:even  => 0,   :odd  => 1  })
f.hashish(2.1, {'even' => 0.0, 'odd' => 1.0})
# f.hashish(2.1, {:even  => 0,   'odd' => 1.0})  # should fail

f.hashmash(2.1, { :evens => [0,2,4], :odds => [1,3,5.5] })
f.bar
f.splatted(1, 3.1, 3.2, 3.3)
f.blurfl(10, 1 => 3, 2 => 5)
f.blurfl(10, 'foo')

class Blurfl
end
bf = Blurfl.new

puts f.ting(['zoe', :trevor, 'nerissa'])
# f.bojack(['a', 1, :foo])
f.bojack [bf, bf, :foo]
f.foo(1, [2], 'foo')

puts f.tuplize(1,2).inspect

puts "Foo signed methods:"
puts "  all      : " + Foo.all_signed_methods.inspect
puts "  called   : " + Foo.called_signed_methods.inspect
puts "  UNcalled : " + Foo.uncalled_signed_methods.inspect

puts "Bar signed methods:"
puts "  called   : " + Bar.called_signed_methods.inspect
puts "  UNcalled : " + Bar.uncalled_signed_methods.inspect

puts "All signed methods:"
puts "  called   : " + Glyde::HasType.called_methods.inspect
puts "  UNcalled : " + Glyde::HasType.uncalled_methods.inspect

puts
puts "actual types:\n" + Glyde::HasType.actual_types

=begin

  # But: what if we had :a and :b?
  # Can it verify that they're not the same?
  # And if we had :a twice?  That they *are* the same?
  #

=end
