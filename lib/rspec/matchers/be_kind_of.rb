module RSpec
  module Matchers
    class BeAKindOf
      include BaseMatcher

      def matches?(actual)
        super(actual).kind_of?(expected)
      end
    end
  end
end
