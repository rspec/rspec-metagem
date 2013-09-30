module RSpec
  module Matchers

    module Composable

      def and(matcher)
        BuiltIn::Composite.new self, matcher
      end

    end

  end
end
