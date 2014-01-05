module RSpec
  module Matchers
    module BuiltIn
      class OutputToStream < BaseMatcher
        def initialize(stream, expected)
          @stream = stream
          @expected = expected
        end

        def matches?(block)
          @actual = capture_stream(block)

          @expected ? @actual == @expected : captured?
        end

        def failure_message
          if @expected
            "expected block to output #{@expected.inspect} to #{formatted_stream}, but output #{formatted_actual}"
          else
            "expected block to output to #{formatted_stream}, but did not"
          end
        end

        def failure_message_when_negated
          if @expected
            "expected block to not output #{@expected.inspect} to #{formatted_stream}, but did"
          else
            "expected block to not output to #{formatted_stream}, but did"
          end
        end

        private

        def capture_stream(block)
          captured_stdout, captured_stderr = StringIO.new, StringIO.new

          orig_stdout = $stdout
          orig_stderr = $stderr
          $stdout = captured_stdout
          $stderr = captured_stderr

          block.call

          orig_stdout == @stream ? captured_stdout.string : captured_stderr.string
        ensure
          $stdout = orig_stdout
          $stderr = orig_stderr
        end

        def captured?
          @actual.length > 0
        end

        def formatted_stream
         @stream == $stdout ? "stdout" : "stderr"
        end

        def formatted_actual
         captured? ? @actual.inspect : "nothing"
        end
      end
    end
  end
end
