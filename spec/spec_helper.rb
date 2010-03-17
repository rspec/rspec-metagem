$LOAD_PATH.unshift(File.expand_path('../../lib', __FILE__))
require 'rspec/core'

$LOAD_PATH << File.expand_path('../../../rspec-expectations/lib', __FILE__)
$LOAD_PATH << File.expand_path('../../../rspec-mocks/lib', __FILE__)
require 'rspec/expectations'
require 'rspec/mocks'

begin
  require 'autotest'
rescue LoadError
  raise "You must install autotest to use it"
end

require 'autotest/rspec2'

Dir['./spec/support/**/*.rb'].map {|f| require f}

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

def use_formatter(new_formatter)
  original_formatter = Rspec.configuration.formatter
  Rspec.configuration.instance_variable_set(:@formatter, new_formatter)
  yield
ensure
  Rspec.configuration.instance_variable_set(:@formatter, original_formatter)
end

def in_editor?
  ENV.has_key?('TM_MODE') || ENV.has_key?('EMACS') || ENV.has_key?('VIM')
end

Rspec.configure do |c|
  c.color_enabled = !in_editor?
  c.exclusion_filter = { :ruby => lambda {|version|
    !(RUBY_VERSION.to_s =~ /^#{version.to_s}/)
  }}
end
