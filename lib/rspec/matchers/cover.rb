module RSpec
  module Matchers
    class Cover
      include BaseMatcher

      def initialize(*expected)
        super(expected)
      end

      def matches?(range)
        expected.all? {|e| super(range).cover?(e)}
      end

      def does_not_match?(range)
        @actual = range
        expected.none? {|e| range.cover?(e)}
      end
    end

    # Passes if actual covers expected. This works for
    # Ranges. You can also pass in multiple args
    # and it will only pass if all args are found in Range.
    #
    # @example
    #   (1..10).should cover(5)
    #   (1..10).should cover(4, 6)
    #   (1..10).should cover(4, 6, 11) # will fail
    #   (1..10).should_not cover(11)
    #   (1..10).should_not cover(5)    # will fail
    #
    # ### Warning:: Ruby >= 1.9 only
    def cover(*values)
      Cover.new(*values)
    end
  end
end
