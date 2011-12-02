dir = File.dirname(__FILE__)
require dir + '/../init'

class Bar
  include Glyde::HasType

  sig_attr_accessor :int, :int2 do Integer end
  sig_attr_reader   :str        do String  end
  attr_reader :foo # no type

  sig do () >> () end
  def self.hello
    puts "class hello!"
  end

  sig do () >> () end
  def initialize
    self.int = 1
    self.int2 = 2
    @str = 'foo'
    @foo = '@foo is untyped.  We do not track calls to it.'
  end

  sig do () >> () end
  def hello
    fleebl("instance hello!")
  end

  private
  
  sig do String >> () end
  def fleebl(str)
    puts str
  end

  sig do Integer >> Integer end
  def blurfl(i)
    i + int + int2
  end
end

b = Bar.new
puts b.int
puts b.str
puts "blurfl: #{b.blurfl(3)}"
b.hello
puts b.foo
b.int = 2
puts b.int
puts "signed methods: "
puts "  all      : " + Bar.all_signed_methods.inspect
puts "  called   : " + Bar.called_signed_methods.inspect
puts "  UNcalled : " + Bar.uncalled_signed_methods.inspect
