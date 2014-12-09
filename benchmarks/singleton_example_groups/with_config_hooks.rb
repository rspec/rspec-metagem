require_relative "helper"

RSpec.configure do |c|
  10.times do
    c.before(:context, :apply_it) { }
    c.after(:context,  :apply_it) { }
  end
end

BenchmarkHelpers.run_benchmarks

__END__

No match -- without singleton group support
                        489.165  (±33.3%) i/s -      2.080k
No match -- with singleton group support
                        451.019  (±29.3%) i/s -      1.890k
Example match -- without singleton group support
                        465.178  (±35.3%) i/s -      1.820k
Example match -- with singleton group support
                        244.273  (±23.3%) i/s -      1.064k
Group match -- without singleton group support
                        406.979  (±27.0%) i/s -      1.700k
Group match -- with singleton group support
                        327.455  (±22.6%) i/s -      1.421k
Both match -- without singleton group support
                        423.859  (±32.1%) i/s -      1.763k
Both match -- with singleton group support
                        293.873  (±23.5%) i/s -      1.333k
