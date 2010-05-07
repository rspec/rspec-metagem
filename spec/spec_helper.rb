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

class Rspec::Core::ExampleGroup
  def self.run_all(reporter=nil)
    run(reporter || Rspec::Mocks::Mock.new('reporter').as_null_object)
  end
end

def in_editor?
  ENV.has_key?('TM_MODE') || ENV.has_key?('EMACS') || ENV.has_key?('VIM')
end

Rspec.configure do |c|
  c.color_enabled = !in_editor?
  c.exclusion_filter = { :ruby => lambda {|version|
    !(RUBY_VERSION.to_s =~ /^#{version.to_s}/)
  }}
  c.before(:each) do
    @real_world = Rspec::Core.world
    Rspec::Core.instance_variable_set(:@world, Rspec::Core::World.new)
  end
  c.after(:each) do
    Rspec::Core.instance_variable_set(:@world, @real_world)
  end
end
