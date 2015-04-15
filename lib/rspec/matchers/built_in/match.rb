module RSpec
  module Matchers
    module BuiltIn
      # @api private
      # Provides the implementation for `match`.
      # Not intended to be instantiated directly.
      class Match < BaseMatcher
        # @api private
        # @return [String]
        def description
          "match #{surface_descriptions_in(expected).inspect}"
        end

        # @api private
        # @return [Boolean]
        def diffable?
          true
        end

      private

        def match(expected, actual)
          return true if values_match?(expected, actual)
          return false unless can_safely_call_match?(expected, actual)
          actual.match(expected)
        end

        def can_safely_call_match?(expected, actual)
          return false unless actual.respond_to?(:match)

          !(RSpec::Matchers.is_a_matcher?(expected) &&
            (String === actual || Regexp === actual))
        end
      end
    end
  end
end
