require 'stringio'

module RSpec
  module Matchers
    module BuiltIn
      class OutputToStream < BaseMatcher
        def initialize(expected)
          @expected = expected
        end

        def matches?(block)
          @actual = @stream.capture(block)

          @expected ? values_match?(@expected, @actual) : captured?
        end

        def to_stdout
          @stream = CaptureStdout.new
          self
        end

        def to_stderr
          @stream = CaptureStderr.new
          self
        end

        def failure_message
          "expected block to #{description}, #{actual_description}"
        end

        def failure_message_when_negated
          "expected block to not #{description}, but did"
        end

        def description
          @expected ? "output #{description_of @expected} to #{@stream.name}" : "output to #{@stream.name}"
        end

        def diffable?
          true
        end

      private

        def captured?
          @actual.length > 0
        end

        def actual_description
          @expected ? "but output #{captured? ? @actual.inspect : 'nothing'}" : "but did not"
        end
      end

      class CaptureStdout
        def name
          'stdout'
        end

        def capture(block)
          captured_stream = StringIO.new

          original_stream = $stdout
          $stdout = captured_stream

          block.call

          captured_stream.string
        ensure
          $stdout = original_stream
        end
      end

      class CaptureStderr
        def name
          'stderr'
        end

        def capture(block)
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
