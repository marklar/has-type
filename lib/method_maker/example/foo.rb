dir = File.dirname(__FILE__)
require dir + '/../init'

class Foo
end

mm = Glyde::MethodMaker.for_method(Foo, :initialize)
mm.create {|s| puts s }

f = Foo.new('foo')

# Should cause NO warnings.
mm.destroy

f = Foo.new('foo')
