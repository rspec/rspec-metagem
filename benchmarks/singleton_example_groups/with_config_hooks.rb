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
                        614.535  (±33.8%) i/s -      2.520k
No match -- with singleton group support
                        555.190  (±21.1%) i/s -      2.496k
Example match -- without singleton group support
                        574.821  (±31.5%) i/s -      2.491k
Example match -- with singleton group support
                        436.391  (±25.2%) i/s -      1.872k
Group match -- without singleton group support
                        544.063  (±31.4%) i/s -      2.112k
Group match -- with singleton group support
                        457.098  (±18.8%) i/s -      1.961k
Both match -- without singleton group support
                        554.004  (±30.1%) i/s -      2.255k
Both match -- with singleton group support
                        452.834  (±19.7%) i/s -      1.935k
