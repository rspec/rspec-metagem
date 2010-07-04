require 'bundler'
Bundler.setup

# TODO (DC 2010-07-04) This next line is necessary when running 'rake spec'.
# Why doesn't the rspec-core ref in Gemfile handle this.
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

class RSpec::Core::ExampleGroup
  def self.run_all(reporter=nil)
    run(reporter || NullObject.new)
  end
end

def in_editor?
  ENV.has_key?('TM_MODE') || ENV.has_key?('EMACS') || ENV.has_key?('VIM')
end

RSpec.configure do |c|
  c.color_enabled = !in_editor?
  c.filter_run :focus => true
  c.run_all_when_everything_filtered = true
  c.filter_run_excluding :ruby => lambda {|version|
    case version.to_s
    when "!jruby"
      RUBY_ENGINE != "jruby"
    else
      !(RUBY_VERSION.to_s =~ /^#{version.to_s}/)
    end
  }
  c.before(:each) do
    @real_world = RSpec.world
    RSpec.instance_variable_set(:@world, RSpec::Core::World.new)
  end
  c.after(:each) do
    RSpec.instance_variable_set(:@world, @real_world)
  end
end
