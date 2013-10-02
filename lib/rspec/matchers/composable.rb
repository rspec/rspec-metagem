module RSpec
  module Matchers

    module Composable

      def and(matcher)
        BuiltIn::Composite.new self, matcher
      end

      def or(matcher)
        BuiltIn::Composite.new self, matcher, :type => :or
      end

    end

  end
end
