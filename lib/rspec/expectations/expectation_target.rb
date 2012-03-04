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

  module Matchers
    def expect(*target, &target_block)
      target << target_block if block_given?
      raise ArgumentError.new("You must pass an argument or a block to #expect but not both.") unless target.size == 1
      ::RSpec::Expectations::ExpectationTarget.new(target.first)
    end
  end
end

