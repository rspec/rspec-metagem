if defined?(Cucumber)
  require 'shellwords'
  Before('~@allow-should-syntax') do
    set_env('SPEC_OPTS', "-r#{Shellwords.escape(__FILE__)}")
  end

  Before('@oneliner-should') do
    set_env('ALLOW_ONELINER_SHOULD', 'true')
  end
else
  module DisallowOneLinerShould
    def should(*)
      raise "one-liner should is not allowed"
    end

    def should_not(*)
      raise "one-liner should_not is not allowed"
    end
  end

  RSpec.configure do |rspec|
    rspec.mock_with :rspec do |mocks|
      mocks.syntax = :expect
    end

    rspec.expect_with :rspec do |expectations|
      expectations.syntax = :expect
    end

    rspec.expose_dsl_globally = false

    rspec.include DisallowOneLinerShould unless ENV['ALLOW_ONELINER_SHOULD']
  end
end
