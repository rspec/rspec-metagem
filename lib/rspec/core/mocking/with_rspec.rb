require 'rspec/mocks/framework'
require 'rspec/mocks/extensions'

module RSpec
  module Core
    module MockFrameworkAdapter

      include RSpec::Mocks::ExampleMethods
      def _setup_mocks
        $rspec_mocks ||= RSpec::Mocks::Space.new
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
