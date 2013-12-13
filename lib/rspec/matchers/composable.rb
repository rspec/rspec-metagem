module RSpec
  module Matchers
    # Mixin designed to support the composable matcher features
    # of RSpec 3+. Mix it into your custom matcher classes to
    # allow them to be used in a composable fashion.
    #
    # @api public
    module Composable
      # Creates a compound `and` expectation. The matcher will
      # only pass if both sub-matchers pass.
      # This can be chained together to form an arbitrarily long
      # chain of matchers.
      #
      # @example
      #   expect(alphabet).to start_with("a").and end_with("z")
      #
      # @note The negative form (`expect(...).not_to matcher.and other`)
      #   is not supported at this time.
      def and(matcher)
        BuiltIn::Compound::And.new self, matcher
      end

      # Creates a compound `or` expectation. The matcher will
      # pass if either sub-matcher passes.
      # This can be chained together to form an arbitrarily long
      # chain of matchers.
      #
      # @example
      #   expect(stoplight.color).to eq("red").or eq("green").or eq("yellow")
      #
      # @note The negative form (`expect(...).not_to matcher.or other`)
      #   is not supported at this time.
      def or(matcher)
        BuiltIn::Compound::Or.new self, matcher
      end

      # Delegates to `#matches?`. Allows matchers to be used in composable
      # fashion and also supports using matchers in case statements.
      def ===(value)
        matches?(value)
      end
    end
  end
end
