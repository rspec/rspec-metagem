module RSpec
  module Matchers
    class Eq < BaseMatcher
      attr_reader :actual
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
        "eq #{@expected.inspect}"
      end
    end
  end
end

