require 'benchmark'

n = 10_000

num_modules = 100

class Foo; end
modules = num_modules.times.map { Module.new }
modules.each {|m| Foo.send(:include, m) }

Benchmark.benchmark do |bm|
  3.times do
    bm.report do
      n.times do
        Foo < modules.first
      end
    end
  end
end

Benchmark.benchmark do |bm|
  3.times do
    bm.report do
      n.times do
        Foo < modules.last
      end
    end
  end
end

Benchmark.benchmark do |bm|
  3.times do
    bm.report do
      n.times do
        Foo.included_modules.include?(modules.first)
      end
    end
  end
end

Benchmark.benchmark do |bm|
  3.times do
    bm.report do
      n.times do
        Foo.included_modules.include?(modules.last)
      end
    end
  end
end

# 100 modules
# < modules.first
  # 0.010000   0.000000   0.010000 (  0.005104)
  # 0.000000   0.000000   0.000000 (  0.005114)
  # 0.010000   0.000000   0.010000 (  0.005076)
# < modules.last
  # 0.000000   0.000000   0.000000 (  0.002180)
  # 0.000000   0.000000   0.000000 (  0.002199)
  # 0.000000   0.000000   0.000000 (  0.002189)
# < included_modules.include?(modules.first)
  # 0.110000   0.010000   0.120000 (  0.110062)
  # 0.100000   0.000000   0.100000 (  0.105343)
  # 0.100000   0.000000   0.100000 (  0.102770)
# < included_modules.include?(modules.last)
  # 0.050000   0.010000   0.060000 (  0.048520)
  # 0.040000   0.000000   0.040000 (  0.049013)
  # 0.050000   0.000000   0.050000 (  0.050668)

# 1000 modules
# < modules.first
  # 0.080000   0.000000   0.080000 (  0.079460)
  # 0.080000   0.000000   0.080000 (  0.078765)
  # 0.080000   0.000000   0.080000 (  0.079560)
# < modules.last
  # 0.000000   0.000000   0.000000 (  0.002195)
  # 0.000000   0.000000   0.000000 (  0.002201)
  # 0.000000   0.000000   0.000000 (  0.002199)
# < included_modules.include?(modules.first)
  # 0.860000   0.010000   0.870000 (  0.887684)
  # 0.870000   0.000000   0.870000 (  0.875158)
  # 0.870000   0.000000   0.870000 (  0.879216)
# < included_modules.include?(modules.last)
  # 0.340000   0.000000   0.340000 (  0.344011)
  # 0.350000   0.000000   0.350000 (  0.346277)
  # 0.330000   0.000000   0.330000 (  0.335607)
