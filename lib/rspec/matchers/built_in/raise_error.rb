module RSpec
  module Matchers
    module BuiltIn
      # @api private
      # Provides the implementation for `raise_error`.
      # Not intended to be instantiated directly.
      # rubocop:disable ClassLength
      class RaiseError
        include Composable

        def initialize(expected_error_or_message=Exception, expected_message=nil, &block)
          @block = block
          @actual_error = nil
          case expected_error_or_message
          when String, Regexp
            @expected_error, @expected_message = Exception, expected_error_or_message
          else
            @expected_error, @expected_message = expected_error_or_message, expected_message
          end
        end

        # @api public
        # Specifies the expected error message.
        def with_message(expected_message)
          raise_message_already_set if @expected_message
          @expected_message = expected_message
          self
        end

        # rubocop:disable MethodLength
        # @private
        def matches?(given_proc, negative_expectation=false, &block)
          @given_proc = given_proc
          @block ||= block
          @raised_expected_error = false
          @with_expected_message = false
          @eval_block = false
          @eval_block_passed = false

          return false unless Proc === given_proc

          begin
            given_proc.call
          rescue Exception => @actual_error
            if values_match?(@expected_error, @actual_error)
              @raised_expected_error = true
              @with_expected_message = verify_message
            end
          end

          unless negative_expectation
            eval_block if @raised_expected_error && @with_expected_message && @block
          end

          expectation_matched?
        end
        # rubocop:enable MethodLength

        # @private
        def does_not_match?(given_proc)
          prevent_invalid_expectations
          !matches?(given_proc, :negative_expectation) && Proc === given_proc
        end

        # @private
        def supports_block_expectations?
          true
        end

        def expects_call_stack_jump?
          true
        end

        # @api private
        # @return [String]
        def failure_message
          @eval_block ? @actual_error.message : "expected #{expected_error}#{given_error}"
        end

        # @api private
        # @return [String]
        def failure_message_when_negated
          "expected no #{expected_error}#{given_error}"
        end

        # @api private
        # @return [String]
        def description
          "raise #{expected_error}"
        end

      private

        def expectation_matched?
          error_and_message_match? && block_matches?
        end

        def error_and_message_match?
          @raised_expected_error && @with_expected_message
        end

        def block_matches?
          @eval_block ? @eval_block_passed : true
        end

        def eval_block
          @eval_block = true
          begin
            @block[@actual_error]
            @eval_block_passed = true
          rescue Exception => err
            @actual_error = err
          end
        end

        def verify_message
          return true if @expected_message.nil?
          values_match?(@expected_message, @actual_error.message)
        end

        def prevent_invalid_expectations
          what_to_raise = if expecting_specific_exception? && @expected_message
                            "`expect { }.not_to raise_error(SpecificErrorClass, message)`"
                          elsif expecting_specific_exception?
                            "`expect { }.not_to raise_error(SpecificErrorClass)`"
                          elsif @expected_message
                            "`expect { }.not_to raise_error(message)`"
                          end

          return unless what_to_raise

          specific_class_error = ArgumentError.new("#{what_to_raise} is not valid, use `expect { }.not_to raise_error` (with no args) instead")
          raise specific_class_error
        end

        def expected_error
          case @expected_message
          when nil
            description_of(@expected_error)
          when Regexp
            "#{@expected_error} with message matching #{@expected_message.inspect}"
          else
            "#{@expected_error} with #{description_of @expected_message}"
          end
        end

        def format_backtrace(backtrace)
          formatter = Matchers.configuration.backtrace_formatter
          formatter.format_backtrace(backtrace)
        end

        def given_error
          return " but was not given a block" unless Proc === @given_proc
          return " but nothing was raised" unless @actual_error

          backtrace = format_backtrace(@actual_error.backtrace)
          [
            ", got #{@actual_error.inspect} with backtrace:",
            *backtrace
          ].join("\n  # ")
        end

        def expecting_specific_exception?
          @expected_error != Exception
        end

        def raise_message_already_set
          raise "`expect { }.to raise_error(message).with_message(message)` is not valid. The matcher only allows the expected message to be specified once"
        end
      end
      # rubocop:enable ClassLength
    end
  end
end
