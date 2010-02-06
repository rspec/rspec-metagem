$LOAD_PATH.unshift(File.expand_path('../../lib', __FILE__))
require 'rspec/core'

require 'rubygems'
$LOAD_PATH << File.expand_path('../../../rspec-expectations/lib', __FILE__)
$LOAD_PATH << File.expand_path('../../../rspec-mocks/lib', __FILE__)
require 'rspec/expectations'
require 'rspec/mocks'

Rspec::Core::ExampleGroup.send(:include, Rspec::Matchers)

def with_ruby(version)
  yield if RUBY_PLATFORM =~ Regexp.compile("^#{version}")
end

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

def remove_last_example_group_from_world
  Rspec::Core.world.example_groups.pop
end

def disconnect_from_world
  example_groups = Rspec::Core.world.example_groups.dup
  Rspec::Core.world.example_groups.clear
  yield
ensure
  Rspec::Core.world.example_groups.clear
  Rspec::Core.world.example_groups.concat(example_groups)
end

def isolated_example_group(*args, &block)
  block ||= lambda {}
  args << 'example group' if args.empty?
  group = Rspec::Core::ExampleGroup.describe(*args, &block)
  remove_last_example_group_from_world
  group
end

def use_formatter(new_formatter)
  original_formatter = Rspec::Core.configuration.formatter
  Rspec::Core.configuration.instance_variable_set(:@formatter, new_formatter)
  yield
ensure
  Rspec::Core.configuration.instance_variable_set(:@formatter, original_formatter)
end

def in_editor?
  ENV.has_key?('TM_MODE') || ENV.has_key?('EMACS') || ENV.has_key?('VIM')
end

Rspec::Core.configure do |c|
  c.mock_framework = :rspec
  c.filter_run :focused => true
  c.run_all_when_everything_filtered = true
  c.color_enabled = !in_editor?
end
