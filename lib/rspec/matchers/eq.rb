module RSpec
  module Matchers
    class Eq
      attr_reader :actual
      def initialize(expected)
        @expected = expected
      end

      def expected
        [@expected]
      end

      def matches?(actual)
        @actual = actual
        @actual == @expected
      end

      def failure_message_for_should
        "\nexpected: #{@expected.inspect}\n     got: #{@actual.inspect}\n\n(compared using ==)\n"
      end

      def failure_message_for_should_not
        "\nexpected: value != #{@expected.inspect}\n     got: #{@actual.inspect}\n\n(compared using ==)\n"
      end

      def diffable?
        true
      end

      def description
        "eq #{@expected}"
      end
    end
  end
end

