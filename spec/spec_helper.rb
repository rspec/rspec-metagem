require 'rubygems' if RUBY_VERSION.to_f < 1.9

require 'rspec/support/spec'

module ArubaLoader
  extend RSpec::Support::WithIsolatedStdErr
  with_isolated_stderr do
    require 'aruba/api'
  end
end

class << RSpec
  attr_writer :configuration, :world
end

if RUBY_PLATFORM == 'java'
  # Works around https://jira.codehaus.org/browse/JRUBY-5678
  require 'fileutils'
  ENV['TMPDIR'] = File.expand_path('../../tmp', __FILE__)
  FileUtils.mkdir_p(ENV['TMPDIR'])
end

$rspec_core_without_stderr_monkey_patch = RSpec::Core::Configuration.new

class RSpec::Core::Configuration
  def self.new(*args, &block)
    super.tap do |config|
      # We detect ruby warnings via $stderr,
      # so direct our deprecations to $stdout instead.
      config.deprecation_stream = $stdout
    end
  end
end

Dir['./spec/support/**/*.rb'].map do |file|
  # Ensure requires are relative to `spec`, which is on the
  # load path. This helps prevent double requires on 1.8.7.
  require file.gsub("./spec/support", "support")
end

module EnvHelpers
  def with_env_vars(vars)
    original = ENV.to_hash
    vars.each { |k, v| ENV[k] = v }

    begin
      yield
    ensure
      ENV.replace(original)
    end
  end

  def without_env_vars(*vars)
    original = ENV.to_hash
    vars.each { |k| ENV.delete(k) }

    begin
      yield
    ensure
      ENV.replace(original)
    end
  end
end

RSpec.configure do |c|
  # structural
  c.alias_it_behaves_like_to 'it_has_behavior'
  c.include(RSpecHelpers)
  c.include Aruba::Api, :file_path => /spec\/command_line/

  c.expect_with :rspec do |expectations|
    expectations.syntax = :expect
  end

  c.mock_with :rspec do |mocks|
    mocks.syntax = :expect
  end

  # runtime options
  c.raise_errors_for_deprecations!
  c.color = true
  c.include EnvHelpers
  c.filter_run_excluding :ruby => lambda {|version|
    case version.to_s
    when "!jruby"
      RUBY_ENGINE == "jruby"
    when /^> (.*)/
      !(RUBY_VERSION.to_s > $1)
    else
      !(RUBY_VERSION.to_s =~ /^#{version.to_s}/)
    end
  }
end
