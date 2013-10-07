module RSpec
  module Matchers

    module Composable

      def and(matcher)
        BuiltIn::AndComposite.new self, matcher
      end

      def or(matcher)
        BuiltIn::OrComposite.new self, matcher
      end

    end

  end
end
