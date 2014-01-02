module RSpec
  module Matchers
    module BuiltIn
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

        def with_message(expected_message)
          raise_message_already_set if @expected_message
          @expected_message = expected_message
          self
        end

        def matches?(given_proc, negative_expectation = false, &block)
          @block ||= block
          @raised_expected_error = false
          @with_expected_message = false
          @eval_block = false
          @eval_block_passed = false

          unless given_proc.respond_to?(:call)
            ::Kernel.warn "`raise_error` was called with non-proc object #{given_proc.inspect}"
            return false
          end

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

        def expectation_matched?
          error_and_message_match? && block_matches?
        end

        def error_and_message_match?
          @raised_expected_error && @with_expected_message
        end

        def block_matches?
          @eval_block ? @eval_block_passed : true
        end

        def does_not_match?(given_proc)
          prevent_invalid_expectations
          !matches?(given_proc, :negative_expectation)
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

        def failure_message
          @eval_block ? @actual_error.message : "expected #{expected_error}#{given_error}"
        end

        def failure_message_when_negated
          "expected no #{expected_error}#{given_error}"
        end

        def description
          "raise #{expected_error}"
        end

        private

        def prevent_invalid_expectations
          if (expecting_specific_exception? || @expected_message)
            what_to_raise = if expecting_specific_exception? && @expected_message
                                  "`expect { }.not_to raise_error(SpecificErrorClass, message)`"
                                elsif expecting_specific_exception?
                                  "`expect { }.not_to raise_error(SpecificErrorClass)`"
                                elsif @expected_message
                                  "`expect { }.not_to raise_error(message)`"
                                end
            specific_class_error = ArgumentError.new("#{what_to_raise} is not valid, use `expect { }.not_to raise_error` (with no args) instead")
            raise specific_class_error
          end
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
    end
  end
end
