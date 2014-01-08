module RSpec
  module Matchers
    module BuiltIn
      class BeBetween < BaseMatcher
        def initialize(min, max)
          @min, @max = min, max
          inclusive
        end

        def inclusive
          @less_than_operator = :<=
          @greater_than_operator = :>=
          @mode = :inclusive
          self
        end

        def exclusive
          @less_than_operator = :<
          @greater_than_operator = :>
          @mode = :exclusive
          self
        end

        def matches?(actual)
          @actual = actual
          comparable? && compare
        rescue ArgumentError
          false
        end

        def failure_message
          "#{super}#{not_comparable_clause}"
        end

        def description
          "be between #{@min.inspect} and #{@max.inspect} (#{@mode})"
        end

      private

        def comparable?
          @actual.respond_to?(@less_than_operator) && @actual.respond_to?(@greater_than_operator)
        end

        def not_comparable_clause
          ", but it does not respond to `#{@less_than_operator}` and `#{@greater_than_operator}`" unless comparable?
        end

        def compare
          @actual.__send__(@greater_than_operator, @min) && @actual.__send__(@less_than_operator, @max)
        end
      end
    end
  end
end
