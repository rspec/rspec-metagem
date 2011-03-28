def add_to_load_path(path, prepend=false)
  path = File.expand_path("../../#{path}/lib", __FILE__)
  if prepend
    $LOAD_PATH.unshift(path) unless $LOAD_PATH.include?(path)
  else
    $LOAD_PATH << path unless $LOAD_PATH.include?(path)
  end
end

require 'test/unit'

# Make it easy to instantiate test cases for our specs.
# Test::Unit::TestCase#initialize is picky about what arguments it expects.
class Test::Unit::TestCase
  def initialize; end
end

add_to_load_path("rspec-expectations", :prepend)
add_to_load_path("rspec-core")
add_to_load_path("rspec-mocks")

require 'rspec/expectations'
require 'rspec/core'
require 'rspec/mocks'

Dir['./spec/support/**/*'].each {|f| require f}

RSpec::configure do |config|
  config.color_enabled = true
  config.filter_run :focused => true
  config.run_all_when_everything_filtered = true
end
