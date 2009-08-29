require 'mocha/standalone'
require 'mocha/object'

module Rspec
  module Core
    module Mocking
      module WithMocha
        # Mocha::Standalone was deprecated as of Mocha 0.9.7.  
        begin
          include Mocha::API
        rescue NameError
          include Mocha::Standalone
        end
        
        alias :_setup_mocks :mocha_setup
        alias :_verify_mocks :mocha_verify
        alias :_teardown_mocks :mocha_teardown

      end
    end
  end
end