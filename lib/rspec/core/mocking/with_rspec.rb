require 'rspec/mocks'

module RSpec
  module Core
    module MockFrameworkAdapter

      include RSpec::Mocks::ExampleMethods

      def _setup_mocks
        RSpec::Mocks::setup
      end

      def _verify_mocks
        RSpec::Mocks::verify
      end

      def _teardown_mocks
        RSpec::Mocks::teardown
      end

    end
  end
end
