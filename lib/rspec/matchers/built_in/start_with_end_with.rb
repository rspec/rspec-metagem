module RSpec
  module Matchers
    module BuiltIn
      class StartWith
        include BaseMatcher
        def initialize(expected)
          @expected = expected.to_s
        end

        def matches?(actual)
          @actual = actual.to_s
          @actual[0, @expected.length] == @expected
        end

        def failure_message_for_should
          "expected '#{@actual}' to start with '#{@expected}'"
        end

        def failure_message_for_should_not
          "expected '#{@actual}' not to start with '#{@expected}'"
        end
      end

      class EndWith
        include BaseMatcher
        def initialize(expected)
          @expected = expected
        end

        def matches?(actual)
          @actual = actual
          @actual[-@expected.length, @expected.length] == @expected
        end

        def failure_message_for_should
          "expected '#{@actual}' to end with '#{@expected}'"
        end

        def failure_message_for_should_not
          "expected '#{@actual}' not to end with '#{@expected}'"
        end
      end
    end
  end
end