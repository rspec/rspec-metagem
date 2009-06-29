require 'rubygems'
require 'spec/matchers'
require 'spec/expectations'
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'spec/core'

Spec::Core::Behaviour.send(:include, Spec::Matchers)

def with_ruby(version)
  yield if RUBY_PLATFORM =~ Regexp.compile("^#{version}")
end

require 'rubygems'
require 'mocha'

require File.expand_path(File.dirname(__FILE__) + "/resources/example_classes")

module Spec
  module Core
    module Matchers
      def fail
        raise_error(::Spec::Expectations::ExpectationNotMetError)
      end

      def fail_with(message)
        raise_error(::Spec::Expectations::ExpectationNotMetError, message)
      end
    end
  end
end

def remove_last_describe_from_world
  Spec::Core.world.behaviours.pop
end

def isolate_behaviour
  if block_given?
    yield
    Spec::Core.world.behaviours.pop
  end
end

def use_formatter(new_formatter)
  original_formatter = Spec::Core.configuration.formatter
  Spec::Core.configuration.instance_variable_set(:@formatter, new_formatter)
  yield
ensure
  Spec::Core.configuration.instance_variable_set(:@formatter, original_formatter)
end

def not_in_editor?
  !(ENV.has_key?('TM_MODE') || ENV.has_key?('EMACS') || ENV.has_key?('VIM'))
end

Spec::Core.configure do |c|
  c.mock_with :mocha
  c.color_enabled = not_in_editor?
  c.filter_run :focused => true
end
