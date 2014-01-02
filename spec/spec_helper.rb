require 'rspec/support/spec'

RSpec::Support::Spec.setup_simplecov do
  minimum_coverage 97
end

Dir['./spec/support/**/*'].each {|f| require f}

module FormattingSupport
  def dedent(string)
    string.gsub(/^\s+\|/, '').chomp
  end
end

RSpec::configure do |config|
  config.color_enabled = true
  config.filter_run :focused
  config.run_all_when_everything_filtered = true
  config.order = :random

  config.include FormattingSupport

  config.expect_with :rspec do |expectations|
    $default_expectation_syntax = expectations.syntax
    expectations.syntax = :expect
  end

  config.mock_with :rspec do |mocks|
    mocks.syntax = :expect
  end

  # Use the doc formatter when running individual files.
  # This is too verbose when running all spec files but
  # is nice for a single file.
  if config.files_to_run.one? && config.formatters.none?
    config.formatter = 'doc'
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

shared_context "with the default expectation syntax" do
  orig_syntax = nil

  before(:all) do
    orig_syntax = RSpec::Matchers.configuration.syntax
    RSpec::Matchers.configuration.reset_syntaxes_to_default
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

require 'rspec/support/spec/in_sub_process'
module TestUnitIntegrationSupport
  include ::RSpec::Support::InSubProcess

  def with_test_unit_loaded
    in_sub_process do
      require 'test/unit'
      load 'rspec/matchers/test_unit_integration.rb'
      yield
    end
  end
end
