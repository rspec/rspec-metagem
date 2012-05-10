module RSpec
  module Expectations
    class ExpectationTarget
      def initialize(target)
        @target = target
      end

      def to(matcher=nil, message=nil, &block)
        prevent_operator_matchers!(:to, matcher)
        RSpec::Expectations::PositiveExpectationHandler.handle_matcher(@target, matcher, message, &block)
      end

      def to_not(matcher=nil, message=nil, &block)
        prevent_operator_matchers!(:to_not, matcher)
        RSpec::Expectations::NegativeExpectationHandler.handle_matcher(@target, matcher, message, &block)
      end
      alias not_to to_not

    private

      def prevent_operator_matchers!(verb, matcher)
        unless matcher
          raise ArgumentError, "The expect syntax does not support operator matchers, " +
                               "so you must pass a matcher to `##{verb}`."
        end

      end
    end
  end
end

