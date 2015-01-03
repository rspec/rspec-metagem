require 'benchmark/ips'
require 'rspec/core/flat_map'

words = %w[ foo bar bazz big small medium large tiny less more good bad mediocre ]

Benchmark.ips do |x|
  x.report("flat_map") do
    words.flat_map(&:codepoints)
  end

  x.report("inject") do
    words.inject([]) { |a, w| a + w.codepoints }
  end

  x.report("FlatMap.flat_map") do
    RSpec::Core::FlatMap.flat_map(words, &:codepoints)
  end
end

__END__

        flat_map    135.128k (± 9.1%) i/s -    680.089k
          inject     98.048k (±10.5%) i/s -    491.370k
FlatMap.flat_map    118.231k (± 7.3%) i/s -    596.530k
