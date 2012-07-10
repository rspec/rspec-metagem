module RSpec
  module Expectations
    # Wraps the target of an expectation.
    # @example
    #   expect(something) # => ExpectationTarget wrapping something
    #
    #   # used with `to`
    #   expect(actual).to eq(3)
    #
    #   # with `to_not`
    #   expect(actual).to_not eq(3)
    class ExpectationTarget
      # @api private
      def initialize(target)
        @target = target
      end

      # Runs the given expectation, passing if `matcher` returns true.
      # @example
      #   expect(value).to eq(5)
      #   expect { perform }.to raise_error
      # @param [Matcher]
      #   matcher
      # @param [String] message optional message to display when the expectation fails
      # @return [Boolean] true if the expectation succeeds (else raises)
      # @see RSpec::Matchers
      def to(matcher=nil, message=nil, &block)
        prevent_operator_matchers(:to, matcher)
        RSpec::Expectations::PositiveExpectationHandler.handle_matcher(@target, matcher, message, &block)
      end

      # Runs the given expectation, passing if `matcher` returns false.
      # @example
      #   expect(value).to_not eq(5)
      #   expect(value).not_to eq(5)
      # @param [Matcher]
      #   matcher
      # @param [String] message optional message to display when the expectation fails
      # @return [Boolean] false if the negative expectation succeeds (else raises)
      # @see RSpec::Matchers
      def to_not(matcher=nil, message=nil, &block)
        prevent_operator_matchers(:to_not, matcher)
        RSpec::Expectations::NegativeExpectationHandler.handle_matcher(@target, matcher, message, &block)
      end
      alias not_to to_not

    private

      def prevent_operator_matchers(verb, matcher)
        return if matcher

        raise ArgumentError, "The expect syntax does not support operator matchers, " +
                             "so you must pass a matcher to `##{verb}`."
      end
    end
  end
end

