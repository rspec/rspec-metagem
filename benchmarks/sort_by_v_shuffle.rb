require "benchmark"

# This benchmark demonstrates the speed of Array#shuffle versus sorting by
# random numbers. This is in reference to ordering examples using the
# --order=rand command line flag. Array#shuffle also respects seeded random via
# Kernel.srand.

LIST = (1..1_000).to_a.freeze

Benchmark.bmbm do |x|
  x.report("sort_by") do
    1_000.times do
      LIST.sort_by { Kernel.rand(LIST.size) }
    end
  end

  x.report("shuffle") do
    1_000.times do
      LIST.shuffle
    end
  end
end

# Ruby 2.0
#
# 21x over 100 list elements:
#
#                 user     system      total        real
#   sort_by   0.080000   0.000000   0.080000 (  0.074924)
#   shuffle   0.000000   0.000000   0.000000 (  0.003535)
#
# 27x over 1,000 list elements:
#
#                 user     system      total        real
#   sort_by   0.870000   0.000000   0.870000 (  0.874661)
#   shuffle   0.030000   0.000000   0.030000 (  0.031949)
#
# 31x over 10,000 list elements:
#
#                 user     system      total        real
#   sort_by  10.690000   0.010000  10.700000 ( 10.695433)
#   shuffle   0.330000   0.010000   0.340000 (  0.342375)
