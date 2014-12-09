require_relative "helper"

RSpec.configure do |c|
  1.upto(10) do
    c.include Module.new, :apply_it
  end
end

BenchmarkHelpers.run_benchmarks

__END__

No match -- without singleton group support
                        519.880  (±33.9%) i/s -      2.162k
No match -- with singleton group support
                        481.334  (±28.5%) i/s -      2.028k
Example match -- without singleton group support
                        491.348  (±29.9%) i/s -      2.068k
Example match -- with singleton group support
                        407.257  (±22.3%) i/s -      1.782k
Group match -- without singleton group support
                        483.403  (±36.4%) i/s -      1.815k
Group match -- with singleton group support
                        424.932  (±29.4%) i/s -      1.804k
Both match -- without singleton group support
                        397.831  (±31.9%) i/s -      1.720k
Both match -- with singleton group support
                        424.233  (±25.5%) i/s -      1.720k
