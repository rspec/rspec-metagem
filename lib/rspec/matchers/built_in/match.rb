module RSpec
  module Matchers
    module BuiltIn
      class Match
        include BaseMatcher

        def matches?(actual)
          super(actual).match(expected)
        end
      end
    end
  end
end
