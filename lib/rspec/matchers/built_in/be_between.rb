module RSpec
  module Matchers
    module BuiltIn
      class BeBetween < BaseMatcher
        def initialize(min, max)
          @min, @max = min, max
        end

        def exclusive
          BeBetweenExclusive.new(@min, @max)
        end

        def matches?(actual)
          @actual = actual
          comparable? and @actual.between?(@min, @max)
        rescue ArgumentError
          false
        end

        def failure_message
          "#{super}#{not_comparable_clause}"
        end

        def description
          "be between #{@min.inspect} and #{@max.inspect} (inclusive)"
        end

        private

        def comparable?
          @actual.respond_to?(:between?)
        end

        def not_comparable_clause
          ", but it does not respond to `between?`" unless comparable?
        end
      end

      class BeBetweenExclusive < BaseMatcher
        def initialize(min, max)
          @min, @max = min, max
        end

        def matches?(actual)
          @actual = actual
          comparable? and compare
        rescue ArgumentError
          false
        end

        def failure_message
          "#{super}#{not_comparable_clause}"
        end

        def description
          "be between #{@min.inspect} and #{@max.inspect} (exclusive)"
        end

        private

        def comparable?
          @actual.respond_to?(:>) and @actual.respond_to?(:<)
        end

        def compare
          @actual > @min and @actual < @max
        end

        def not_comparable_clause
          ", but it does not respond to `<` and `>`" unless comparable?
        end
      end
    end
  end
end
