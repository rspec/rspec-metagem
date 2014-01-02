$LOAD_PATH.unshift "./lib"
require 'benchmark'
require 'rspec/expectations'
require 'securerandom'

extend RSpec::Matchers

sizes = [10, 100, 1000, 2000, 4000]

puts "rspec-expectations #{RSpec::Expectations::Version::STRING} -- #{RUBY_ENGINE}/#{RUBY_VERSION}"

puts
puts "Failing `match_array` expectation with lists of distinct strings having 1 unmatched pair"
puts

Benchmark.benchmark do |bm|
  sizes.each do |size|
    actual = Array.new(size) { SecureRandom.uuid }

    expecteds = Array.new(3) do
      array = actual.shuffle
      # replace one entry with a different value
      array[rand(array.length)] = SecureRandom.uuid
      array
    end

    expecteds.each do |expected|
      bm.report("#{size.to_s.rjust(5)} items") do
        begin
          expect(actual).to match_array(expected)
        rescue RSpec::Expectations::ExpectationNotMetError
        else
          raise "did not fail but should have"
        end
      end
    end
  end
end

__END__

Before new composable matchers algo:

   10 items  0.000000   0.000000   0.000000 (  0.000813)
   10 items  0.000000   0.000000   0.000000 (  0.000099)
   10 items  0.000000   0.000000   0.000000 (  0.000127)
  100 items  0.000000   0.000000   0.000000 (  0.000707)
  100 items  0.000000   0.000000   0.000000 (  0.000612)
  100 items  0.000000   0.000000   0.000000 (  0.000600)
 1000 items  0.040000   0.000000   0.040000 (  0.038679)
 1000 items  0.040000   0.000000   0.040000 (  0.041379)
 1000 items  0.040000   0.000000   0.040000 (  0.036680)
 2000 items  0.130000   0.000000   0.130000 (  0.131681)
 2000 items  0.120000   0.000000   0.120000 (  0.123664)
 2000 items  0.130000   0.000000   0.130000 (  0.128799)
 4000 items  0.490000   0.000000   0.490000 (  0.489446)
 4000 items  0.510000   0.000000   0.510000 (  0.511915)
 4000 items  0.480000   0.010000   0.490000 (  0.477616)

After:

   10 items  0.000000   0.000000   0.000000 (  0.001382)
   10 items  0.000000   0.000000   0.000000 (  0.000156)
   10 items  0.000000   0.000000   0.000000 (  0.000161)
  100 items  0.010000   0.000000   0.010000 (  0.005052)
  100 items  0.000000   0.000000   0.000000 (  0.004991)
  100 items  0.010000   0.000000   0.010000 (  0.004984)
 1000 items  0.470000   0.000000   0.470000 (  0.470043)
 1000 items  0.500000   0.000000   0.500000 (  0.499316)
 1000 items  0.490000   0.000000   0.490000 (  0.488582)
 2000 items  1.910000   0.000000   1.910000 (  1.917279)
 2000 items  1.930000   0.010000   1.940000 (  1.931002)
 2000 items  1.920000   0.000000   1.920000 (  1.928989)
 4000 items  7.860000   0.010000   7.870000 (  7.881995)
 4000 items  7.980000   0.010000   7.990000 (  8.003643)
 4000 items  8.000000   0.010000   8.010000 (  8.031382)

