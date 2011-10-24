module RSpec
  module Matchers
    class Eql
      include BaseMatcher

      def matches?(actual)
        super(actual).eql?(expected)
      end

      def failure_message_for_should
        "\nexpected: #{expected.inspect}\n     got: #{actual.inspect}\n\n(compared using eql?)\n"
      end

      def failure_message_for_should_not
        "\nexpected: value != #{expected.inspect}\n     got: #{actual.inspect}\n\n(compared using eql?)\n"
      end

      def diffable?
        true
      end
    end

    # Passes if +actual.eql?(expected)+
    #
    # See http://www.ruby-doc.org/core/classes/Object.html#M001057 for more information about equality in Ruby.
    #
    # @example
    #
    #   5.should eql(5)
    #   5.should_not eql(3)
    def eql(expected)
      Eql.new(expected)
    end
  end
end
