require_relative "helper"

1.upto(10) do |i|
  RSpec.shared_context "context #{i}", :apply_it do
  end
end

BenchmarkHelpers.run_benchmarks

__END__

No match -- without singleton group support
                        503.700  (±33.2%) i/s -      2.184k
No match -- with singleton group support
                        471.018  (±26.8%) i/s -      2.009k
Example match -- without singleton group support
                        467.859  (±34.8%) i/s -      2.021k in   5.600106s
Example match -- with singleton group support
                         84.138  (±34.5%) i/s -    296.000  in   5.515586s
Group match -- without singleton group support
                        384.144  (±27.9%) i/s -      1.560k
Group match -- with singleton group support
                        349.301  (±27.5%) i/s -      1.288k
Both match -- without singleton group support
                        388.100  (±25.8%) i/s -      1.702k
Both match -- with singleton group support
                        339.310  (±20.3%) i/s -      1.504k
