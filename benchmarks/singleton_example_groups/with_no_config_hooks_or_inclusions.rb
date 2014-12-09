require_relative "helper"

BenchmarkHelpers.run_benchmarks

__END__

No match -- without singleton group support
                        504.865  (±31.9%) i/s -      2.128k
No match -- with singleton group support
                        463.115  (±26.6%) i/s -      1.998k
Example match -- without singleton group support
                        472.825  (±31.9%) i/s -      1.938k
Example match -- with singleton group support
                        436.539  (±33.9%) i/s -      1.840k
Group match -- without singleton group support
                        460.643  (±33.4%) i/s -      1.892k
Group match -- with singleton group support
                        430.339  (±23.2%) i/s -      1.911k
Both match -- without singleton group support
                        406.712  (±26.6%) i/s -      1.848k
Both match -- with singleton group support
                        470.299  (±26.4%) i/s -      1.890k
