module RSpec
  module Matchers
    module BuiltIn
      # @api private
      # Provides the implementation for `match`.
      # Not intended to be instantiated directly.
      class Match < BaseMatcher
        def description
          "match #{surface_descriptions_in(expected).inspect}"
        end

        def diffable?
          true
        end

      private

        def match(expected, actual)
          return true if values_match?(expected, actual)
          actual.match(expected) if actual.respond_to?(:match)
        end
      end
    end
  end
end
