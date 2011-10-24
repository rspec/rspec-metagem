module RSpec
  module Matchers
    class BeWithin
      include BaseMatcher

      attr_reader :delta

      def initialize(delta)
        @delta = delta
      end

      def matches?(actual)
        unless defined?(@expected)
          raise ArgumentError.new("You must set an expected value using #of: be_within(#{delta}).of(expected_value)")
        end
        (super(actual) - expected).abs < delta
      end

      def of(expected)
        @expected = expected
        self
      end

      def failure_message_for_should
        "expected #{actual} to #{description}"
      end

      def failure_message_for_should_not
        "expected #{actual} not to #{description}"
      end

      def description
        "be within #{delta} of #{expected}"
      end
    end

    # Passes if actual == expected +/- delta
    #
    # @example
    #
    #   result.should be_within(0.5).of(3.0)
    #   result.should_not be_within(0.5).of(3.0)
    def be_within(delta)
      BeWithin.new(delta)
    end
  end
end
