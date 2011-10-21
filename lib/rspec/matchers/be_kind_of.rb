module RSpec
  module Matchers
    class BeKindOf
      include BaseMatcher

      def matches?(actual)
        super(actual).kind_of?(expected)
      end

      def description
        "be a kind of #{expected.name}"
      end
    end
  end
end
