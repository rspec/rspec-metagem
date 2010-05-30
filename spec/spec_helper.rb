require 'rubygems'
require 'spork'

class Spork::TestFramework::RSpec < Spork::TestFramework
  def run_tests(argv, stderr, stdout)
    ::RSpec::Core::Runner.new.run(argv, stderr, stdout)
  end
end

Spork.prefork do
  $LOAD_PATH.unshift(File.expand_path('../../lib', __FILE__))
  require 'rspec/core'

  $LOAD_PATH << File.expand_path('../../../rspec-expectations/lib', __FILE__)
  $LOAD_PATH << File.expand_path('../../../rspec-mocks/lib', __FILE__)
  require 'rspec/expectations'
  require 'rspec/mocks'

  begin
    require 'autotest'
  rescue LoadError
    raise "Could not load autotest."
  end

  require 'autotest/rspec2'

  Dir['./spec/support/**/*.rb'].map {|f| require f}

  module RSpec
    module Core
      module Matchers
        def fail
          raise_error(::RSpec::Expectations::ExpectationNotMetError)
        end

        def fail_with(message)
          raise_error(::RSpec::Expectations::ExpectationNotMetError, message)
        end
      end
    end
  end

  class RSpec::Core::ExampleGroup
    include RSpec::Matchers
    def self.run_all(reporter=nil)
      run(reporter || RSpec::Mocks::Mock.new('reporter').as_null_object)
    end
  end

  def in_editor?
    ENV.has_key?('TM_MODE') || ENV.has_key?('EMACS') || ENV.has_key?('VIM')
  end

  RSpec.configure do |c|
    c.color_enabled = !in_editor?
    c.exclusion_filter = { :ruby => lambda {|version|
      !(RUBY_VERSION.to_s =~ /^#{version.to_s}/)
    }}
    c.before(:each) do
      @real_world = RSpec.world
      RSpec.instance_variable_set(:@world, RSpec::Core::World.new)
    end
    c.after(:each) do
      RSpec.instance_variable_set(:@world, @real_world)
    end
  end
end

Spork.each_run do
end

