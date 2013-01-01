def add_to_load_path(path, prepend=false)
  path = File.expand_path("../../#{path}/lib", __FILE__)
  if prepend
    $LOAD_PATH.unshift(path) unless $LOAD_PATH.include?(path)
  else
    $LOAD_PATH << path unless $LOAD_PATH.include?(path)
  end
end

require 'test/unit'

add_to_load_path("rspec-expectations", :prepend)
add_to_load_path("rspec-core")
add_to_load_path("rspec-mocks")

require 'rspec/expectations'
require 'rspec/core'
require 'rspec/mocks'

Dir['./spec/support/**/*'].each {|f| require f}

RSpec::configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.color_enabled = true
  config.filter_run :focused
  config.run_all_when_everything_filtered = true
  config.order = :random

  config.expect_with :rspec do |expectations|
    $default_expectation_syntax = expectations.syntax
    expectations.syntax = :expect
  end
end

shared_context "with #should enabled", :uses_should do
  orig_syntax = nil

  before(:all) do
    orig_syntax = RSpec::Matchers.configuration.syntax
    RSpec::Matchers.configuration.syntax = [:expect, :should]
  end

  after(:all) do
    RSpec::Matchers.configuration.syntax = orig_syntax
  end
end

