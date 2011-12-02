dir = File.dirname(__FILE__)

test_files = %w(
  test_parser
  test_hash_map
  test_list
  test_product
  test_signature
  test_splat
  test_sum
  test_type
)

test_files.each do |f|
  require "./#{dir}/#{f}"
end
