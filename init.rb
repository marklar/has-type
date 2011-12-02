dir = File.dirname(__FILE__)

# require 'rubygems'
# require 'glyde/methodmaker'
require dir + '/lib/method_maker/init'

%w(
  type/type
  type/bool
  type/block
  type/hash_map
  type/list
  type/opt
  type/product
  type/splat
  type/sum
  type/variable
  core
  type_mismatch
  recorder
  parser
  declaration
  signature
  has_type
  class_methods
).each do |f|
  require (dir + '/lib/' + f)
end
