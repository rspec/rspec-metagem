module RSpec
  module Matchers
    class BeAnInstanceOf
      include BaseMatcher

      def matches?(actual)
        super(actual).instance_of?(expected)
      end
    end
  end
end
