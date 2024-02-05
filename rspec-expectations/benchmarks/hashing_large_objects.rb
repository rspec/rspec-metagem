require 'benchmark/ips'

OBJECT_VARIABLES = Object.instance_method(:instance_variables)
OBJECT_VARIABLE_GET = Object.instance_method(:instance_variable_get)

def calculate_attribute_hashes(object)
  OBJECT_VARIABLES.bind(object).call.map { |name| OBJECT_VARIABLE_GET.bind(object).call(name).hash }
end

[10, 100, 1000, 10000].each do |object_size|
  klass = Class.new do
    define_method(:initialize) do
      object_size.times do |i|
        instance_variable_set(:"@my_var_#{i}", 'a' * (rand * 100))
      end
    end
  end
  instance = klass.new

  Benchmark.ips do |ips|
    ips.report("Get hashes for object of size: #{instance.instance_variables.size}") do
      calculate_attribute_hashes(instance)
    end
  end
end

# Warming up --------------------------------------
# Get hashes for object of size: 10
#                         14.412k i/100ms
# Calculating -------------------------------------
# Get hashes for object of size: 10
#                         158.585k (± 5.2%) i/s -    792.660k in   5.012663s
# Warming up --------------------------------------
# Get hashes for object of size: 100
#                          1.664k i/100ms
# Calculating -------------------------------------
# Get hashes for object of size: 100
#                          17.041k (± 9.0%) i/s -     84.864k in   5.036735s
# Warming up --------------------------------------
# Get hashes for object of size: 1000
#                        173.000  i/100ms
# Calculating -------------------------------------
# Get hashes for object of size: 1000
#                           1.808k (± 4.6%) i/s -      9.169k in   5.082355s
# Warming up --------------------------------------
# Get hashes for object of size: 10000
#                         16.000  i/100ms
# Calculating -------------------------------------
# Get hashes for object of size: 10000
#                         176.298  (± 3.4%) i/s -    896.000  in   5.089070s
