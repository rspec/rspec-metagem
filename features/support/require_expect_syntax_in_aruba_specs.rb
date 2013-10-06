if defined?(Cucumber)
  require 'shellwords'
  Before do
    set_env('SPEC_OPTS', "-r#{Shellwords.escape(__FILE__)}")
  end
else
  RSpec.configure do |rspec|
    rspec.mock_with :rspec do |mocks|
      mocks.syntax = :expect
    end

    rspec.expect_with :rspec do |expectations|
      expectations.syntax = :expect
    end
  end
end
