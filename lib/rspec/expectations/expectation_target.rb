module RSpec
  module Expectations
    class ExpectationTarget
      def initialize(target)
        @target = target
      end

      def to(matcher=nil, message=nil, &block)
        RSpec::Expectations::PositiveExpectationHandler.handle_matcher(@target, matcher, message, &block)
      end

      def to_not(matcher=nil, message=nil, &block)
        RSpec::Expectations::NegativeExpectationHandler.handle_matcher(@target, matcher, message, &block)
      end
      alias not_to to_not
    end
  end
end

