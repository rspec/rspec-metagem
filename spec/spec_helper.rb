$LOAD_PATH << File.expand_path('../../../rspec-core/lib', __FILE__)
$LOAD_PATH << File.expand_path('../../../rspec-mocks/lib', __FILE__)
$LOAD_PATH.unshift(File.expand_path('../../lib', __FILE__))
require 'rspec/mocks'
require 'rspec/core'
require 'rspec/expectations'

Dir['./spec/support/**/*'].each do |f|
  require f
end

def with_ruby(version)
  yield if RUBY_PLATFORM =~ Regexp.compile("^#{version}")
end

module Rspec
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
    def fail
      raise_error(Rspec::Expectations::ExpectationNotMetError)
    end

    def fail_with(message)
      raise_error(Rspec::Expectations::ExpectationNotMetError, message)
    end
  end
end

Rspec::configure do |config|
  config.mock_with(:rspec)
  config.include Rspec::Mocks::Methods
  config.color_enabled = true
end
