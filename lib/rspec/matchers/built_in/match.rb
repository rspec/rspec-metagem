module RSpec
  module Matchers
    module BuiltIn
      class Match < BaseMatcher
        def match(expected, actual)
          return true if values_match?(expected, actual)
          actual.match(expected) if actual.respond_to?(:match)
        end

        def description
          "match #{surface_descriptions_in(expected).inspect}"
        end

        def diffable?
          true
        end
      end
    end
  end
end
