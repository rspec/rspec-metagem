module Rspec
  module Core
    class Configuration
      def mock_with(use_me_to_mock)
        self.mock_framework = use_me_to_mock
      end
    end
  end
end
