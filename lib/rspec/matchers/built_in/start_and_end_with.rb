module RSpec
  module Matchers
    module BuiltIn
      # @api private
      # Base class for the `end_with` and `start_with` matchers.
      # Not intended to be instantiated directly.
      class StartAndEndWith < BaseMatcher
        def initialize(*expected)
          @actual_does_not_have_ordered_elements = false
          @expected = expected.length == 1 ? expected.first : expected
        end

        # @api private
        # @return [String]
        def failure_message
          super.tap do |msg|
            if @actual_does_not_have_ordered_elements
              msg << ", but it does not have ordered elements"
            elsif !actual.respond_to?(:[])
              msg << ", but it cannot be indexed using #[]"
            end
          end
        end

        # @api private
        # @return [String]
        def description
          return super unless Hash === expected
          "#{name_to_sentence} #{surface_descriptions_in(expected).inspect}"
        end

      private

        def match(expected, actual)
          return false unless actual.respond_to?(:[])

          begin
            return subset_matches? if expected.respond_to?(:length)
            element_matches?
          rescue ArgumentError
            @actual_does_not_have_ordered_elements = true
            return false
          end
        end

        def actual_is_unordered
          ArgumentError.new("#{actual.inspect} does not have ordered elements")
        end
      end

      # @api private
      # Provides the implementation for `start_with`.
      # Not intended to be instantiated directly.
      class StartWith < StartAndEndWith
      private

        def subset_matches?
          values_match?(expected, actual[0, expected.length])
        end

        def element_matches?
          values_match?(expected, actual[0])
        end
      end

      # @api private
      # Provides the implementation for `end_with`.
      # Not intended to be instantiated directly.
      class EndWith < StartAndEndWith
      private

        def subset_matches?
          values_match?(expected, actual[-expected.length, expected.length])
        end

        def element_matches?
          values_match?(expected, actual[-1])
        end
      end
    end
  end
end
