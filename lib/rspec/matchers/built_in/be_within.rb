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
          raise needs_expected unless defined? @expected
          numeric? && (@actual - @expected).abs <= @tolerance
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
          "expected #{@actual.inspect} to #{description}#{not_numeric_clause}"
        end

        def failure_message_when_negated
          "expected #{@actual.inspect} not to #{description}"
        end

        def description
          "be within #{@delta}#{@unit} of #{@expected}"
        end

      private

        def numeric?
          @actual.respond_to?(:-)
        end

        def needs_expected
          ArgumentError.new "You must set an expected value using #of: be_within(#{@delta}).of(expected_value)"
        end

        def not_numeric_clause
          ", but it could not be treated as a numeric value" unless numeric?
        end
      end
    end
  end
end
