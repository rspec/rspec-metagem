module RSpec
  module Matchers
    module BuiltIn
      class Match
        include BaseMatcher

        def initialize(expected)
          @expected = expected
        end

        def matches?(actual)
          @actual = actual
          @actual.match @expected
        end
      end
    end
  end
end
