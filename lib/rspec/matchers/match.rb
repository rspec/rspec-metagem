module RSpec
  module Matchers
    class Match
      include BaseMatcher

      def matches?(actual)
        super(actual).match(expected)
      end
    end

    # Given a Regexp or String, passes if actual.match(pattern)
    #
    # @example
    #
    #   email.should match(/^([^\s]+)((?:[-a-z0-9]+\.)+[a-z]{2,})$/i)
    #   email.should match("@example.com")
    def match(expected)
      Match.new(expected)
    end
  end
end
