require 'spec/mocks/framework'
require 'spec/mocks/extensions'

module Spec
  module Core
    module Mocking
      module WithRspec
        include Spec::Mocks::ExampleMethods
        def _setup_mocks
          $rspec_mocks ||= Spec::Mocks::Space.new
        end
        def _verify_mocks
          $rspec_mocks.verify_all
        end
        def _teardown_mocks
          $rspec_mocks.reset_all
        end
      end
    end
  end
end
