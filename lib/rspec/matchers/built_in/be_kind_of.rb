module RSpec
  module Matchers
    module BuiltIn
      class BeAKindOf
        include BaseMatcher

        def initialize(expected)
          @expected = expected
        end

        def matches?(actual)
          (@actual = actual).kind_of?(@expected)
        end
      end
    end
  end
end
