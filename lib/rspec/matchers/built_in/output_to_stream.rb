require 'stringio'

module RSpec
  module Matchers
    module BuiltIn
      class OutputToStream < BaseMatcher
        def initialize(expected)
          @expected = expected
        end

        def matches?(block)
          @actual = capture_stream(block)

          @expected ? @actual == @expected : captured?
        end

        def failure_message
          if @expected
            "expected block to output #{@expected.inspect} to #{stream_name}, but output #{formatted_actual}"
          else
            "expected block to output to #{stream_name}, but did not"
          end
        end

        def failure_message_when_negated
          if @expected
            "expected block to not output #{@expected.inspect} to #{stream_name}, but did"
          else
            "expected block to not output to #{stream_name}, but did"
          end
        end

      private

        def captured?
          @actual.length > 0
        end

        def formatted_actual
          captured? ? @actual.inspect : "nothing"
        end
      end

      class OutputToStdout < OutputToStream
        def capture_stream(block)
          captured_stream = StringIO.new

          @original_stream = $stdout
          $stdout = captured_stream

          block.call

          captured_stream.string
        ensure
          $stdout = @original_stream
        end

        def stream_name
          'stdout'
        end
      end

      class OutputToStderr < OutputToStream
        def capture_stream(block)
          captured_stream = StringIO.new

          @original_stream = $stderr
          $stderr = captured_stream

          block.call

          captured_stream.string
        ensure
          $stderr = @original_stream
        end

        def stream_name
          'stderr'
        end
      end
    end
  end
end
