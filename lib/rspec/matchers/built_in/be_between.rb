module RSpec
  module Matchers
    module BuiltIn
      class BeBetween < BaseMatcher
        include Composable

        def initialize(min, max)
          @min, @max = min, max
        end

        def matches?(actual)
          @actual = actual
          comparable? and @actual.between?(@min, @max)
        end

        def failure_message
          "expected #{@actual.inspect} to #{description}#{not_comparable_clause}"
        end

        def failure_message_when_negated
          "expected #{@actual.inspect} not to #{description}"
        end

        def description
          "be between #{@min.inspect} and #{@max.inspect} (inclusive)"
        end

      private

        def comparable?
          @actual.respond_to?(:between?)
        end

        def not_comparable_clause
          ", but #{@actual.inspect} does not respond to `between?`" unless comparable?
        end
      end
    end
  end
end
