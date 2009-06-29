require 'mocha/standalone'
require 'mocha/object'

module Spec
  module Core
    module Mocking
      module WithMocha
        include Mocha::Standalone

        alias :_setup_mocks :mocha_setup
        alias :_verify_mocks :mocha_verify
        alias :_teardown_mocks :mocha_teardown

      end
    end
  end
end