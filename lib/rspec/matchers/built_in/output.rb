require 'stringio'

module RSpec
  module Matchers
    module BuiltIn
      # @api private
      # Provides the implementation for `output`.
      # Not intended to be instantiated directly.
      class Output < BaseMatcher
        def initialize(expected)
          @expected        = expected
          @actual          = ""
          @block           = nil
          @stream_capturer = NullCapture
        end

        def matches?(block)
          @block = block
          return false unless Proc === block
          @actual = @stream_capturer.capture(block)
          @expected ? values_match?(@expected, @actual) : captured?
        end

        def does_not_match?(block)
          !matches?(block) && Proc === block
        end

        # @api public
        # Tells the matcher to match against stdout.
        def to_stdout
          @stream_capturer = CaptureStdout
          self
        end

        # @api public
        # Tells the matcher to match against stderr.
        def to_stderr
          @stream_capturer = CaptureStderr
          self
        end

        # @api private
        # @return [String]
        def failure_message
          "expected block to #{description}, but #{positive_failure_reason}"
        end

        # @api private
        # @return [String]
        def failure_message_when_negated
          "expected block to not #{description}, but #{negative_failure_reason}"
        end

        # @api private
        # @return [String]
        def description
          if @expected
            "output #{description_of @expected} to #{@stream_capturer.name}"
          else
            "output to #{@stream_capturer.name}"
          end
        end

        # @api private
        # @return [Boolean]
        def diffable?
          true
        end

        # @api private
        # Indicates this matcher matches against a block.
        # @return [True]
        def supports_block_expectations?
          true
        end

      private

        def captured?
          @actual.length > 0
        end

        def positive_failure_reason
          return "was not a block" unless Proc === @block
          return "output #{actual_output_description}" if @expected
          "did not"
        end

        def negative_failure_reason
          return "was not a block" unless Proc === @block
          "output #{actual_output_description}"
        end

        def actual_output_description
          return "nothing" unless captured?
          @actual.inspect
        end
      end

      # @private
      module NullCapture
        def self.name
          "some stream"
        end

        def self.capture(_block)
          raise "You must chain `to_stdout` or `to_stderr` off of the `output(...)` matcher."
        end
      end

      # @private
      module CaptureStdout
        def self.name
          'stdout'
        end

        def self.capture(block)
          captured_stream = StringIO.new

          original_stream = $stdout
          $stdout = captured_stream

          block.call

          captured_stream.string
        ensure
          $stdout = original_stream
        end
      end

      # @private
      module CaptureStderr
        def self.name
          'stderr'
        end

        def self.capture(block)
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
