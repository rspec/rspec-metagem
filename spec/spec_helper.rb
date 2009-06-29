$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '../../core/lib'))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '../../mocks/lib'))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'spec/expectations'
require 'rspec/mocks'

require 'spec/deprecation'
require 'spec/ruby'
require 'spec/example'
require 'rspec/core'

module Spec  
  # module Example
  #   class NonStandardError < Exception; end
  # end
  # 
  module Matchers
    def fail_with(message)
      raise_error(Spec::Expectations::ExpectationNotMetError, message)
    end
  end
end

Rspec::Core::configure do |config|
  config.mock_with(:rspec)
  config.include Rspec::Mocks::Methods
  config.include Spec::Matchers
end