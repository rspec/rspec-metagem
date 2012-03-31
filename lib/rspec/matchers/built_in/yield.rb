module RSpec
  module Matchers
    module BuiltIn
      module YieldMatcherHelpers
      private
        def assert_valid_expect_block(block)
          return if block.arity == 1
          raise "Your expect block must accept an argument to be used with this " +
                "matcher. Pass the argument as a block on to the method you are testing."
        end
      end

      class YieldControl
        include BaseMatcher
        include YieldMatcherHelpers

        def matches?(block)
          assert_valid_expect_block block
          yielded = false
          block.call(lambda { |*| yielded = true })
          yielded
        end

        def failure_message_for_should
          "expected given block to yield control"
        end

        def failure_message_for_should_not
          "expected given block not to yield control"
        end
      end

      class YieldWithNoArgs
        include BaseMatcher
        include YieldMatcherHelpers

        def matches?(block)
          assert_valid_expect_block block
          yielded, args = false, nil
          block.call(lambda { |*a| yielded = true; args = a })
          @yielded, @args = yielded, args
          @yielded && @args.none?
        end

        def failure_message_for_should
          "expected given block to yield with no arguments, but #{failure_reason}"
        end

        def failure_message_for_should_not
          "expected given block not to yield with no arguments, but did"
        end

      private

        def failure_reason
          if !@yielded
            "did not yield"
          else
            "yielded with arguments: #{@args.inspect}"
          end
        end
      end

      class YieldWithArgs
        include YieldMatcherHelpers

        def initialize(*args)
          @expected = args
        end

        def matches?(block)
          assert_valid_expect_block block
          yielded, actual = false, nil
          block.call(lambda { |*a| yielded = true; actual = a })
          @yielded, @actual = yielded, actual
          @yielded && args_match?
        end

        def failure_message_for_should
          "expected given block to yield with arguments, but #{positive_failure_reason}"
        end

        def failure_message_for_should_not
          "expected given block not to yield with arguments, but #{negative_failure_reason}"
        end

        def description
          desc = "yield with args"
          desc << "(" + @expected.map { |e| e.inspect }.join(", ") + ")" if @expected.any?
          desc
        end

      private

        def positive_failure_reason
          if !@yielded
            "did not yield"
          else
            @positive_args_failure
          end
        end

        def negative_failure_reason
          if all_args_match?
            "yielded with expected arguments" +
              "\nexpected not: #{@expected.inspect}" +
              "\n         got: #{@actual.inspect} (compared using === and ==)"
          else
            "did"
          end
        end

        def args_match?
          if @expected.none? # expect {...}.to yield_with_args
            @positive_args_failure = "yielded with no arguments" if @actual.none?
            return @actual.any?
          end

          unless match = all_args_match?
            @positive_args_failure = "yielded with unexpected arguments" +
              "\nexpected: #{@expected.inspect}" +
              "\n     got: #{@actual.inspect} (compared using === and ==)"
          end

          match
        end

        def all_args_match?
          return false if @expected.size != @actual.size

          @expected.zip(@actual).all? do |expected, actual|
            expected === actual || actual == expected
          end
        end
      end

      class YieldSuccessiveArgs
        include YieldMatcherHelpers

        def initialize(*args)
          @expected = args
        end

        def matches?(block)
          assert_valid_expect_block block
          actual = []
          block.call(lambda { |a| actual << a })
          @actual = actual
          args_match?
        end

        def failure_message_for_should
          "expected given block to yield successively with arguments, but yielded with unexpected arguments" +
            "\nexpected: #{@expected.inspect}" +
            "\n     got: #{@actual.inspect} (compared using === and ==)"
        end

        def failure_message_for_should_not
          "expected given block not to yield successively with arguments, but yielded with expected arguments" +
              "\nexpected not: #{@expected.inspect}" +
              "\n         got: #{@actual.inspect} (compared using === and ==)"
        end

        def description
          desc = "yield successive args"
          desc << "(" + @expected.map { |e| e.inspect }.join(", ") + ")"
          desc
        end

      private

        def args_match?
          return false if @expected.size != @actual.size

          @expected.zip(@actual).all? do |expected, actual|
            expected === actual || actual == expected
          end
        end
      end
    end
  end
end

