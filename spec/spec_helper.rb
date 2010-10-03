require 'rspec/core'
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

class NullObject
  def method_missing(method, *args, &block)
    # ignore
  end
end

module RSpec::Core
  class SandboxedExampleGroup < ExampleGroup
    def self.run(reporter=nil)
      @orig_mock_space = RSpec::Mocks::space
      RSpec::Mocks::space = RSpec::Mocks::Space.new
      super(reporter || NullObject.new)
    ensure
      RSpec::Mocks::space = @orig_mock_space
    end
  end
end

def sandboxed(&block)
  begin
    @orig_config = RSpec.configuration
    @orig_world  = RSpec.world
    new_config = RSpec::Core::Configuration.new
    new_config.include(RSpec::Matchers)
    new_world  = RSpec::Core::World.new(new_config)
    RSpec.instance_variable_set(:@configuration, new_config)
    RSpec.instance_variable_set(:@world, new_world)
    object = Object.new
    object.extend(RSpec::Core::ObjectExtensions)
    object.extend(RSpec::Core::SharedExampleGroup)

    @orig_example_group_class = RSpec::Core::const_get(:ExampleGroup)
    RSpec::Core::__send__ :remove_const, :ExampleGroup
    RSpec::Core::const_set(:ExampleGroup, RSpec::Core::SandboxedExampleGroup)
    object.instance_eval(&block)
  ensure
    RSpec::Core::__send__ :remove_const, :ExampleGroup
    RSpec::Core::const_set(:ExampleGroup, @orig_example_group_class)
    RSpec.instance_variable_set(:@configuration, @orig_config)
    RSpec.instance_variable_set(:@world, @orig_world)
  end
end

def in_editor?
  ENV.has_key?('TM_MODE') || ENV.has_key?('EMACS') || ENV.has_key?('VIM')
end

RSpec.configure do |c|
  c.color_enabled = !in_editor?
  c.filter_run :focused => true
  c.run_all_when_everything_filtered = true
  c.filter_run_excluding :ruby => lambda {|version|
    case version.to_s
    when "!jruby"
      RUBY_ENGINE != "jruby"
    when /^> (.*)/
      !(RUBY_VERSION.to_s > $1)
    else
      !(RUBY_VERSION.to_s =~ /^#{version.to_s}/)
    end
  }
  c.around do |example|
    sandboxed { example.run }
  end
end
