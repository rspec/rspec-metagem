module RSpec
  module Matchers
    module BuiltIn
      class BeWithin
        include BaseMatcher

        attr_reader :delta

        def initialize(delta)
          @delta = delta
        end

        def matches?(actual)
          check_presence_of_expected
          check_actual_is_numeric(actual)

          (super(actual) - expected).abs <= delta
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

        private

        def check_presence_of_expected
          unless defined?(@expected)
            raise ArgumentError.new("You must set an expected value using #of: be_within(#{delta}).of(expected_value)")
          end
        end

        def check_actual_is_numeric(actual)
          unless actual.is_a? Numeric
            raise ArgumentError, "The actual value (#{actual.inspect}) must be of a `Numeric` type"
          end
        end
      end
    end
  end
end
