$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '../../core/lib'))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '../../mocks/lib'))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'rspec/expectations'
require 'rspec/mocks'
require 'rspec/core'

module Spec
  module Ruby
    class << self
      def version
        RUBY_VERSION
      end
    end
  end
end

module Rspec  
  module Matchers
    def fail_with(message)
      raise_error(Rspec::Expectations::ExpectationNotMetError, message)
    end
  end
end

Rspec::Core::configure do |config|
  config.mock_with(:rspec)
  config.include Rspec::Mocks::Methods
  config.include Rspec::Matchers
  config.color_enabled = true
end