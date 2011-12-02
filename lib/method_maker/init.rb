dir = File.dirname(__FILE__)

%w(
  method_maker
  base
  class_method
  instance_method
).each do |f|
  require (dir + '/lib/' + f)
end
