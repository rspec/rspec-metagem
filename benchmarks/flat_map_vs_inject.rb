require 'benchmark/ips'
require 'rspec/core/flat_map'

words = %w[ foo bar bazz big small medium large tiny less more good bad mediocre ]

Benchmark.ips do |x|
  x.report("flat_map") do
    words.flat_map(&:codepoints)
  end

  x.report("inject (+)") do
    words.inject([]) { |a, w| a + w.codepoints }
  end

  x.report("inject (concat)") do
    words.inject([]) { |a, w| a.concat w.codepoints }
  end

  x.report("FlatMap.flat_map") do
    RSpec::Core::FlatMap.flat_map(words, &:codepoints)
  end
end

__END__
        flat_map    136.445k (± 5.8%) i/s -    682.630k
      inject (+)     99.557k (±10.0%) i/s -    496.368k
 inject (concat)    120.902k (±14.6%) i/s -    598.400k
FlatMap.flat_map    121.461k (± 8.5%) i/s -    608.826k
