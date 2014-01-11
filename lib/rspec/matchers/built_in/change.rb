module RSpec
  module Matchers
    module BuiltIn
      # Describes an expected mutation.
      class Change
        include Composable

        # Specifies the delta of the expected change.
        def by(expected_delta)
          ChangeRelatively.new(@change_details, expected_delta, :by) do |actual_delta|
            values_match?(expected_delta, actual_delta)
          end
        end

        # Specifies a minimum delta of the expected change.
        def by_at_least(minimum)
          ChangeRelatively.new(@change_details, minimum, :by_at_least) do |actual_delta|
            actual_delta >= minimum
          end
        end

        # Specifies a maximum delta of the expected change.
        def by_at_most(maximum)
          ChangeRelatively.new(@change_details, maximum, :by_at_most) do |actual_delta|
            actual_delta <= maximum
          end
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
          "expected #{@change_details.message} to have changed, but is still #{description_of @change_details.actual_before}"
        end

        # @api private
        def failure_message_when_negated
          "expected #{@change_details.message} not to have changed, but did change from #{description_of @change_details.actual_before} to #{description_of @change_details.actual_after}"
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

        def initialize(change_details, expected_delta, relativity, &comparer)
          @change_details = change_details
          @expected_delta = expected_delta
          @relativity     = relativity
          @comparer       = comparer
        end

        def failure_message
          "expected #{@change_details.message} to have changed #{@relativity.to_s.gsub("_", " ")} #{description_of @expected_delta}, " +
          "but was changed by #{description_of @change_details.actual_delta}"
        end

        def matches?(event_proc)
          @change_details.perform_change(event_proc)
          @comparer.call(@change_details.actual_delta)
        end

        def does_not_match?(event_proc)
          raise NotImplementedError, "`expect { }.not_to change { }.#{@relativity}()` is not supported"
        end

        # @api private
        def description
          "change #{@change_details.message} #{@relativity.to_s.gsub("_", " ")} #{description_of @expected_delta}"
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

        def description
          "change #{@change_details.message} #{change_description}"
        end

        def failure_message
          return before_value_failure   unless matches_before?
          return did_not_change_failure unless @change_details.changed?
          after_value_failure
        end

      private

        def matches_before?
          values_match?(@expected_before, @change_details.actual_before)
        end

        def matches_after?
          values_match?(@expected_after, @change_details.actual_after)
        end

        def before_value_failure
          "expected #{@change_details.message} to have initially been #{description_of @expected_before}, but was #{description_of @change_details.actual_before}"
        end

        def after_value_failure
          "expected #{@change_details.message} to have changed to #{description_of @expected_after}, but is now #{description_of @change_details.actual_after}"
        end

        def did_not_change_failure
          "expected #{@change_details.message} to have changed #{change_description}, but did not change"
        end

        def did_change_failure
          "expected #{@change_details.message} not to have changed, but did change from #{description_of @change_details.actual_before} to #{description_of @change_details.actual_after}"
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
          @description_suffix = " to #{description_of value}"
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
          return before_value_failure unless matches_before?
          did_change_failure
        end

      private

        def change_description
          "from #{description_of @expected_before}#{@description_suffix}"
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
          @description_suffix = " from #{description_of value}"
          self
        end

        def does_not_match?(event_proc)
          raise NotImplementedError, "`expect { }.not_to change { }.to()` is not supported"
        end

      private

        def change_description
          "to #{description_of @expected_after}#{@description_suffix}"
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
