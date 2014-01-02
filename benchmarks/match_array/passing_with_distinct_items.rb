$LOAD_PATH.unshift "./lib"
require 'benchmark'
require 'rspec/expectations'
require 'securerandom'

extend RSpec::Matchers

sizes = [10, 100, 1000, 2000, 4000]

puts "rspec-expectations #{RSpec::Expectations::Version::STRING} -- #{RUBY_ENGINE}/#{RUBY_VERSION}"

puts
puts "Passing `match_array` expectation with lists of distinct strings"
puts

Benchmark.benchmark do |bm|
  sizes.each do |size|
    actual    = Array.new(size) { SecureRandom.uuid }
    expecteds = Array.new(3)    { actual.shuffle }
    expecteds.each do |expected|
      bm.report("#{size.to_s.rjust(5)} items") do
        expect(actual).to match_array(expected)
      end
    end
  end
end

__END__

Before new composable matchers algo:

   10 items  0.000000   0.000000   0.000000 (  0.000857)
   10 items  0.000000   0.000000   0.000000 (  0.000029)
   10 items  0.000000   0.000000   0.000000 (  0.000018)
  100 items  0.000000   0.000000   0.000000 (  0.000334)
  100 items  0.000000   0.000000   0.000000 (  0.000372)
  100 items  0.000000   0.000000   0.000000 (  0.000331)
 1000 items  0.030000   0.000000   0.030000 (  0.029778)
 1000 items  0.030000   0.000000   0.030000 (  0.030566)
 1000 items  0.030000   0.000000   0.030000 (  0.033150)
 2000 items  0.140000   0.000000   0.140000 (  0.141719)
 2000 items  0.120000   0.000000   0.120000 (  0.124348)
 2000 items  0.120000   0.000000   0.120000 (  0.121202)
 4000 items  0.490000   0.000000   0.490000 (  0.500631)
 4000 items  0.470000   0.000000   0.470000 (  0.468477)
 4000 items  0.490000   0.010000   0.500000 (  0.492957)

After:

   10 items  0.000000   0.000000   0.000000 (  0.001165)
   10 items  0.000000   0.000000   0.000000 (  0.000131)
   10 items  0.000000   0.000000   0.000000 (  0.000127)
  100 items  0.000000   0.000000   0.000000 (  0.005636)
  100 items  0.010000   0.000000   0.010000 (  0.004881)
  100 items  0.000000   0.000000   0.000000 (  0.004676)
 1000 items  0.500000   0.000000   0.500000 (  0.505676)
 1000 items  0.490000   0.000000   0.490000 (  0.483469)
 1000 items  0.490000   0.000000   0.490000 (  0.497841)
 2000 items  1.950000   0.000000   1.950000 (  1.966324)
 2000 items  1.970000   0.000000   1.970000 (  1.975567)
 2000 items  1.900000   0.000000   1.900000 (  1.902315)
 4000 items  7.650000   0.010000   7.660000 (  7.672907)
 4000 items  7.720000   0.010000   7.730000 (  7.735615)
 4000 items  7.730000   0.000000   7.730000 (  7.756837)

