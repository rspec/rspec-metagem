module RSpec
  module Matchers
    module BuiltIn
      class BeBetween < BaseMatcher
        def initialize(min, max)
          @min, @max = min, max
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
    end
  end
end
