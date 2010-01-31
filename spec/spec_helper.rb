dir = File.dirname(__FILE__)
lib_path = File.expand_path("#{dir}/../lib")
$LOAD_PATH.unshift lib_path unless $LOAD_PATH.include?(lib_path)

require 'rubygems'
$LOAD_PATH.unshift(File.expand_path('../../../expectations/lib'), __FILE__)
require 'rspec/expectations'
$LOAD_PATH.unshift(File.expand_path('../../../mocks/lib'), __FILE__)
require 'rspec/mocks'
$LOAD_PATH.unshift(File.expand_path('../../lib'), __FILE__)
require 'rspec/core'

Rspec::Core::ExampleGroup.send(:include, Rspec::Matchers)

def with_ruby(version)
  yield if RUBY_PLATFORM =~ Regexp.compile("^#{version}")
end

require 'rubygems'

module Rspec
  module Core
    module Matchers
      def fail
        raise_error(::Rspec::Expectations::ExpectationNotMetError)
      end

      def fail_with(message)
        raise_error(::Rspec::Expectations::ExpectationNotMetError, message)
      end
    end
  end
end

def remove_last_describe_from_world
  Rspec::Core.world.behaviours.pop
end

def isolate_example_group
  if block_given?
    example_groups = Rspec::Core.world.behaviours.dup
    begin
      Rspec::Core.world.behaviours.clear
      yield
    ensure
      Rspec::Core.world.behaviours.clear
      Rspec::Core.world.behaviours.concat(example_groups)
    end
  end
end

def double_describe(*args)
  group = Rspec::Core::ExampleGroup.describe(*args) {}
  remove_last_describe_from_world
  yield group if block_given?
  group
end

def use_formatter(new_formatter)
  original_formatter = Rspec::Core.configuration.formatter
  Rspec::Core.configuration.instance_variable_set(:@formatter, new_formatter)
  yield
ensure
  Rspec::Core.configuration.instance_variable_set(:@formatter, original_formatter)
end

def not_in_editor?
  !(ENV.has_key?('TM_MODE') || ENV.has_key?('EMACS') || ENV.has_key?('VIM'))
end

Rspec::Core.configure do |c|
  c.mock_framework = :rspec
  # TODO: Filter run needs normal before/after/include filter logic
  c.filter_run :focused => true
  c.color_enabled = not_in_editor?
end
