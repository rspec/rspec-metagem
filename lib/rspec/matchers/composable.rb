module RSpec
  module Matchers

    module Composable

      def and(matcher)
        BuiltIn::Compound::And.new self, matcher
      end

      def or(matcher)
        BuiltIn::Compound::Or.new self, matcher
      end

    end

  end
end
