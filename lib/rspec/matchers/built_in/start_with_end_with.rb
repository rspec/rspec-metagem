module RSpec
  module Matchers
    module BuiltIn
      class StartWith
        include BaseMatcher
        def initialize(expected)
          @expected = expected
        end

        def matches?(actual)
          @actual = actual
          if @actual.respond_to?(:[])
            if @expected.respond_to?(:length)
              @actual[0, @expected.length] == @expected
            else
              @actual[0] == @expected
            end
          else
            raise ArgumentError.new("#{@expected.inspect} does not respond to :[]")
          end
        end

        def failure_message_for_should
          "expected #{@actual.inspect} to start with #{@expected.inspect}"
        end

        def failure_message_for_should_not
          "expected #{@actual.inspect} not to start with #{@expected.inspect}"
        end
      end

      class EndWith
        include BaseMatcher
        def initialize(expected)
          @expected = expected
        end

        def matches?(actual)
          @actual = actual
          if @actual.respond_to?(:[])
            if @expected.respond_to?(:length)
              @actual[-@expected.length, @expected.length] == @expected
            else
              @actual[-1] == @expected
            end
          else
            raise ArgumentError.new("#{@expected.inspect} does not respond to :[]")
          end
        end

        def failure_message_for_should
          "expected #{@actual.inspect} to end with #{@expected.inspect}"
        end

        def failure_message_for_should_not
          "expected #{@actual.inspect} not to end with #{@expected.inspect}"
        end
      end
    end
  end
end