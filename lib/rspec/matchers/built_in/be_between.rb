module RSpec
  module Matchers
    module BuiltIn
      class BeBetween < BaseMatcher
        def initialize(min, max)
          @min, @max = min, max
        end

        def matches?(actual)
          @actual = actual
          @actual.between?(@min, @max)
        end

        def description
          "be between #{@min.inspect} and #{@max.inspect} (inclusive)"
        end
      end
    end
  end
end
