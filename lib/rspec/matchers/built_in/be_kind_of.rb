module RSpec
  module Matchers
    module BuiltIn
      class BeAKindOf
        include BaseMatcher

        def matches?(actual)
          super(actual).kind_of?(expected)
        end
      end
    end
  end
end
