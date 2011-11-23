$:.unshift File.expand_path("../../lib", __FILE__)
require 'benchmark'

n = 20

Benchmark.benchmark do |bm|
  3.times do
    bm.report do
      n.times do
        fork do
          require 'rspec/expectations'
        end
      end
    end
  end
end
