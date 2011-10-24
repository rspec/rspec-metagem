module RSpec
  module Matchers
    class Eq
      include BaseMatcher

      def matches?(actual)
        super(actual) == expected
      end

      def failure_message_for_should
        "\nexpected: #{expected.inspect}\n     got: #{actual.inspect}\n\n(compared using ==)\n"
      end

      def failure_message_for_should_not
        "\nexpected: value != #{expected.inspect}\n     got: #{actual.inspect}\n\n(compared using ==)\n"
      end

      def diffable?
        true
      end
    end

    # Passes if <tt>actual == expected</tt>.
    #
    # See http://www.ruby-doc.org/core/classes/Object.html#M001057 for more information about equality in Ruby.
    #
    # @example
    #
    #   5.should eq(5)
    #   5.should_not eq(3)
    def eq(expected)
      Eq.new(expected)
    end
  end
end

