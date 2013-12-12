module RSpec
  module Matchers
    module BuiltIn
      class BeWithin
        include Composable

        def initialize(delta)
          @delta = delta
        end

        def matches?(actual)
          @actual = actual
          raise needs_expected     unless defined? @expected
          raise needs_subtractable unless @actual.respond_to? :-
          (@actual - @expected).abs <= @tolerance
        end

        def of(expected)
          @expected  = expected
          @tolerance = @delta
          @unit      = ''
          self
        end

        def percent_of(expected)
          @expected  = expected
          @tolerance = @delta * @expected.abs / 100.0
          @unit      = '%'
          self
        end

        def failure_message
          "expected #{@actual} to #{description}"
        end

        def failure_message_when_negated
          "expected #{@actual} not to #{description}"
        end

        def description
          "be within #{@delta}#{@unit} of #{@expected}"
        end

        private

        def needs_subtractable
          ArgumentError.new "The actual value (#{@actual.inspect}) must respond to `-`"
        end

        def needs_expected
          ArgumentError.new "You must set an expected value using #of: be_within(#{@delta}).of(expected_value)"
        end
      end
    end
  end
end
