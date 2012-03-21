module RSpec
  module Matchers
    module BuiltIn
      class YieldControl
        def matches?(block)
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
        def matches?(block)
          @yielded, @args = false, nil
          block.call(lambda { |*a| @yielded = true; @args = a })
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
        attr_reader :expected, :actual
        def initialize(*args)
          @expected = args
        end

        def matches?(block)
          @yielded, @actual = false, nil
          block.call(lambda { |*a| @yielded = true; @actual = a })
          @yielded && args_match?
        end

        def failure_message_for_should
          "expected given block to yield with arguments, but #{failure_reason}"
        end

        def failure_message_for_should_not
          "expected given block not to yield with arguments, but did"
        end

        def diffable?
          true
        end

      private

        def failure_reason
          if !@yielded
            "did not yield"
          else
            @args_failure
          end
        end

        def args_match?
          if @expected.none? # expect {...}.to yield_with_args
            @args_failure = "yielded with no arguments" if @actual.none?
            return @actual.any?
          end

          unless match = all_args_match?
            @args_failure = "yielded with unexpected arguments" +
              "\nexpected: #{expected.inspect}" +
              "\n     got: #{actual.inspect} (compared using ===)"
          end

          match
        end

        def all_args_match?
          return false if @expected.size != @actual.size

          @expected.zip(@actual).all? do |expected, actual|
            expected === actual
          end
        end
      end
    end
  end
end

