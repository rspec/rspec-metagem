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

  # http://en.wikipedia.org/wiki/Fisher-Yates_shuffle
  #
  # We use this algorithm as an alternative to `shuffle` on
  # rubies (< 1.9.3) for which Array#shuffle does not accept
  # a `:random` option. We do this to avoid affecting ruby's
  # global randomization.
  x.report('fisher-yates') do
    1_000.times do
      rng = Random.new
      list = LIST.dup
      LIST.size.times do |i|
        j = i + rng.rand(LIST.size - i)
        next if i == j
        list[i], list[j] = list[j], list[i]
      end
    end
  end
end

=begin

Ruby 2.0.0:

Rehearsal ------------------------------------------------
sort_by        0.570000   0.010000   0.580000 (  0.581875)
shuffle        0.020000   0.000000   0.020000 (  0.021524)
fisher-yates   0.370000   0.020000   0.390000 (  0.387855)
--------------------------------------- total: 0.990000sec

                   user     system      total        real
sort_by        0.560000   0.000000   0.560000 (  0.561014)
shuffle        0.010000   0.000000   0.010000 (  0.019814)
fisher-yates   0.350000   0.010000   0.360000 (  0.358932)

Ruby 1.9.3:

Rehearsal ------------------------------------------------
sort_by        0.690000   0.010000   0.700000 (  0.701035)
shuffle        0.020000   0.000000   0.020000 (  0.017603)
fisher-yates   0.440000   0.020000   0.460000 (  0.464778)
--------------------------------------- total: 1.180000sec

                   user     system      total        real
sort_by        0.690000   0.000000   0.690000 (  0.697824)
shuffle        0.020000   0.000000   0.020000 (  0.018622)
fisher-yates   0.440000   0.010000   0.450000 (  0.452260)

JRuby:

Rehearsal ------------------------------------------------
sort_by        2.550000   0.050000   2.600000 (  1.325000)
shuffle        0.090000   0.000000   0.090000 (  0.057000)
fisher-yates   0.770000   0.010000   0.780000 (  0.477000)
--------------------------------------- total: 3.470000sec

                   user     system      total        real
sort_by        0.470000   0.010000   0.480000 (  0.442000)
shuffle        0.040000   0.000000   0.040000 (  0.042000)
fisher-yates   0.300000   0.010000   0.310000 (  0.283000)

=end
