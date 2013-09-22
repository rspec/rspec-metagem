unless ENV['NO_COVERALLS']
  require 'simplecov' if RUBY_VERSION.to_f >= 1.9
  require 'coveralls'
  Coveralls.wear! do
    add_filter '/bundle/'
    add_filter '/spec/'
    add_filter '/tmp/'
  end
end

Dir['./spec/support/**/*'].each {|f| require f}

module DeprecationHelpers
  def expect_deprecation_with_call_site(file, line)
    expect(RSpec.configuration.reporter).to receive(:deprecation) do |options|
      expect(options[:call_site]).to include([file, line].join(':'))
    end
  end
end

RSpec::configure do |config|
  config.include DeprecationHelpers
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


shared_context "with #should exclusively enabled", :uses_only_should do
  orig_syntax = nil

  before(:all) do
    orig_syntax = RSpec::Matchers.configuration.syntax
    RSpec::Matchers.configuration.syntax = :should
  end

  after(:all) do
    RSpec::Matchers.configuration.syntax = orig_syntax
  end
end

module TestUnitIntegrationSupport
  include InSubProcess

  def with_test_unit_loaded
    in_sub_process do
      require 'test/unit'
      load 'rspec/matchers/test_unit_integration.rb'
      yield
    end
  end
end
