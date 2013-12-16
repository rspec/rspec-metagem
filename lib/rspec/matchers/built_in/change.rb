module RSpec
  module Matchers
    module BuiltIn
      # Describes an expected mutation.
      class Change
        include Composable

        # Specifies the delta of the expected change.
        def by(expected_delta)
          ChangeRelatively.new(@change_details, expected_delta, :==, :by)
        end

        # Specifies a minimum delta of the expected change.
        def by_at_least(minimum)
          ChangeRelatively.new(@change_details, minimum, :>=, :by_at_least)
        end

        # Specifies a maximum delta of the expected change.
        def by_at_most(maximum)
          ChangeRelatively.new(@change_details, maximum, :<=, :by_at_most)
        end

        # Specifies the new value you expect.
        def to(value)
          ChangeToValue.new(@change_details, value)
        end

        # Specifies the original value.
        def from(value)
          ChangeFromValue.new(@change_details, value)
        end

        # @api private
        def matches?(event_proc)
          raise_block_syntax_error if block_given?
          @change_details.perform_change(event_proc)
          @change_details.changed?
        end

        # @api private
        def failure_message
          "expected #{@change_details.message} to have changed, but is still #{@change_details.actual_before.inspect}"
        end

        # @api private
        def failure_message_when_negated
          "expected #{@change_details.message} not to have changed, but did change from #{@change_details.actual_before.inspect} to #{@change_details.actual_after.inspect}"
        end

        # @api private
        def description
          "change #{@change_details.message}"
        end

      private

        def initialize(receiver=nil, message=nil, &block)
          @change_details = ChangeDetails.new(receiver, message, &block)
        end

        def raise_block_syntax_error
          raise SyntaxError,
            "The block passed to the `change` matcher must use `{ ... }` instead of do/end"
        end
      end

      # Used to specify a relative change.
      # @api private
      class ChangeRelatively
        include Composable

        def initialize(change_details, expected_delta, comparison, relativity)
          @change_details = change_details
          @expected_delta = expected_delta
          @comparison     = comparison
          @relativity     = relativity
        end

        def failure_message
          "expected #{@change_details.message} to have changed #{@relativity.to_s.gsub("_", " ")} #{@expected_delta.inspect}, " +
          "but was changed by #{@change_details.actual_delta.inspect}"
        end

        def matches?(event_proc)
          @change_details.perform_change(event_proc)
          @change_details.actual_delta.__send__(@comparison, @expected_delta)
        end

        def does_not_match?(event_proc)
          raise NotImplementedError, "`expect { }.not_to change { }.#{@relativity}()` is not supported"
        end

        # @api private
        def description
          "change #{@change_details.message} #{@relativity.to_s.gsub("_", " ")} #{@expected_delta.inspect}"
        end
      end

      # Base class for specifying a change from and/or to specific values.
      # @api private
      class SpecificValuesChange
        include Composable
        MATCH_ANYTHING = ::Object.ancestors.last

        def initialize(change_details, from, to)
          @change_details  = change_details
          @expected_before = from
          @expected_after  = to
        end

        def matches?(event_proc)
          @change_details.perform_change(event_proc)
          @change_details.changed? && matches_before? && matches_after?
        end

        def failure_message
          if !matches_before?
            "expected #{@change_details.message} to have initially been #{@expected_before.inspect}, but was #{@change_details.actual_before.inspect}"
          else
            "expected #{@change_details.message} to have changed to #{failure_message_for_expected_after}, but is now #{@change_details.actual_after.inspect}"
          end
        end

      private

        def matches_before?
          expected_matches_actual?(@expected_before, @change_details.actual_before)
        end

        def matches_after?
          expected_matches_actual?(@expected_after, @change_details.actual_after)
        end

        def expected_matches_actual?(expected, actual)
          expected === actual || actual == expected
        end

        def failure_message_for_expected_after
          if RSpec::Matchers.is_a_matcher?(@expected_after)
            @expected_after.description
          else
            @expected_after.inspect
          end
        end
      end

      # Used to specify a change from a specific value
      # (and, optionally, to a specific value).
      # @api private
      class ChangeFromValue < SpecificValuesChange
        def initialize(change_details, expected_before)
          @description_suffix = nil
          super(change_details, expected_before, MATCH_ANYTHING)
        end

        def to(value)
          @expected_after     = value
          @description_suffix = " to #{value.inspect}"
          self
        end

        def does_not_match?(event_proc)
          if @description_suffix
            raise NotImplementedError, "`expect { }.not_to change { }.to()` is not supported"
          end

          @change_details.perform_change(event_proc)
          !@change_details.changed? && matches_before?
        end

        def failure_message_when_negated
          if !matches_before?
            "expected #{@change_details.message} to have initially been #{@expected_before.inspect}, but was #{@change_details.actual_before.inspect}"
          else
            "expected #{@change_details.message} not to have changed, but did change from #{@change_details.actual_before.inspect} to #{@change_details.actual_after.inspect}"
          end
        end

        def description
          "change #{@change_details.message} from #{@expected_before.inspect}#{@description_suffix}"
        end
      end

      # Used to specify a change to a specific value
      # (and, optionally, from a specific value).
      # @api private
      class ChangeToValue < SpecificValuesChange
        def initialize(change_details, expected_after)
          @description_suffix = nil
          super(change_details, MATCH_ANYTHING, expected_after)
        end

        def from(value)
          @expected_before    = value
          @description_suffix = " from #{value.inspect}"
          self
        end

        def does_not_match?(event_proc)
          raise NotImplementedError, "`expect { }.not_to change { }.to()` is not supported"
        end

        def description
          "change #{@change_details.message} to #{@expected_after.inspect}#{@description_suffix}"
        end
      end

      # Encapsulates the details of the before/after values.
      # @api private
      class ChangeDetails
        attr_reader :message, :actual_before, :actual_after

        def initialize(receiver=nil, message=nil, &block)
          @message    = message ? "##{message}" : "result"
          @value_proc = block || lambda { receiver.__send__(message) }
        end

        def perform_change(event_proc)
          @actual_before = evaluate_value_proc
          event_proc.call
          @actual_after = evaluate_value_proc
        end

        def changed?
          @actual_before != @actual_after
        end

        def actual_delta
          @actual_after - @actual_before
        end

      private

        def evaluate_value_proc
          case val = @value_proc.call
          when Enumerable, String
            val.dup
          else
            val
          end
        end
      end
    end
  end
end
