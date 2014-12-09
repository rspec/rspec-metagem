require_relative "helper"

RSpec.configure do |c|
  10.times do
    c.before(:context, :apply_it) { }
    c.after(:context,  :apply_it) { }
    c.include Module.new, :apply_it
  end
end

1.upto(10) do |i|
  RSpec.shared_context "context #{i}", :apply_it do
  end
end

BenchmarkHelpers.run_benchmarks

__END__

No match -- without singleton group support
                        452.015  (±33.8%) i/s -      1.900k
No match -- with singleton group support
                        464.520  (±31.0%) i/s -      1.887k
Example match -- without singleton group support
                        476.961  (±34.6%) i/s -      1.978k in   5.340615s
Example match -- with singleton group support
                         76.177  (±34.1%) i/s -    266.000
Group match -- without singleton group support
                        364.554  (±28.3%) i/s -      1.372k
Group match -- with singleton group support
                        281.761  (±24.1%) i/s -      1.200k
Both match -- without singleton group support
                        281.521  (±27.4%) i/s -      1.188k
Both match -- with singleton group support
                        297.886  (±18.1%) i/s -      1.288k
