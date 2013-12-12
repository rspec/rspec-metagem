module RSpec
  module Matchers
    module Composable
      def and(matcher)
        BuiltIn::Compound::And.new self, matcher
      end

      def or(matcher)
        BuiltIn::Compound::Or.new self, matcher
      end

      # Delegates to #matches?. Allows matchers to be used in composable
      # fashion and also supports using matchers in case statements.
      def ===(value)
        matches?(value)
      end
    end
  end
end
