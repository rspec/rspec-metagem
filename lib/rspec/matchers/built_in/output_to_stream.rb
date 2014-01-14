require 'stringio'

module RSpec
  module Matchers
    module BuiltIn
      class OutputToStream < BaseMatcher
        def initialize(stream_name, expected)
          @stream_name = stream_name
          @expected    = expected
        end

        def matches?(block)
          @actual = capture_stream(block)

          @expected ? values_match?(@expected, @actual) : captured?
        end

        def failure_message
          "expected block to #{description}, #{actual_description}"
        end

        def failure_message_when_negated
          "expected block to not #{description}, but did"
        end

        def description
          @expected ? "output #{description_of @expected} to #{@stream_name}" : "output to #{@stream_name}"
        end

      private

        def captured?
          @actual.length > 0
        end

        def actual_description
          @expected ? "but output #{captured? ? @actual.inspect : 'nothing'}" : "but did not"
        end
      end

      class OutputToStdout < OutputToStream
        def initialize(expected)
          super('stdout', expected)
        end

        def capture_stream(block)
          captured_stream = StringIO.new

          original_stream = $stdout
          $stdout = captured_stream

          block.call

          captured_stream.string
        ensure
          $stdout = original_stream
        end
      end

      class OutputToStderr < OutputToStream
        def initialize(expected)
          super('stderr', expected)
        end

        def capture_stream(block)
          captured_stream = StringIO.new

          original_stream = $stderr
          $stderr = captured_stream

          block.call

          captured_stream.string
        ensure
          $stderr = original_stream
        end
      end
    end
  end
end
