$LOAD_PATH.unshift File.expand_path("../../../lib", __FILE__)
require 'rspec/core'
require 'allocation_stats'

def benchmark_allocations
  stats = AllocationStats.new(burn: 1).trace do
    yield
  end

  columns = if ENV['DETAIL']
              [:sourcefile, :sourceline, :class_plus]
            else
              [:class_plus]
            end

  puts stats.allocations(alias_paths: true).group_by(*columns).from_pwd.sort_by_size.to_text
end
