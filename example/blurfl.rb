dir = File.dirname(__FILE__)
require dir + '/../init'

class Bar
  include Glyde::HasType
  # type :MyHash, {Symbol|String => Integer|Float}
  # sig :'self.bar', o{ MyHash >> MyHash }

  sig do {Symbol|String => Integer|Float} >> Hash end
  def self.bar(h)
    h
  end

  sig do (Integer|Float) * splat(String|Symbol) >> Integer end
  def splatted(i, *a)
    i
  end

  sig do [String] >> String * Integer end
  def listed(strs)
    [strs.join("\n"), 1]
  end

  sig do Integer * opt(String) * opt(String) >> String end
  def defaults(i, s1='bar', s2='foo')
    s1 + i.to_s + s2
  end
end

class Foo
  include Glyde::HasType

  sig do () >> () end
  def self.foo
    puts 'in Foo.foo'
  end
end

b = Bar.new
puts b.listed(['a', 'b', 'c']).inspect
puts b.defaults(1)

puts Foo.foo.inspect

puts Bar.bar('a' => 1.0, :b => 2).inspect
# puts b.splatted(1, 'foo', 'bar', :baz).inspect

# puts Bar.bar('should fail').inspect

puts 'Bar methods'
puts '  all:      ' + Bar.all_signed_methods.inspect
puts '  called:   ' + Bar.called_signed_methods.inspect
puts '  UNcalled: ' + Bar.uncalled_signed_methods.inspect

# type sig suggestions, based on diff from declaration
# (in case decl is too permissive)
