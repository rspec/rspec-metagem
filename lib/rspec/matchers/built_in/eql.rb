module RSpec
  module Matchers
    module BuiltIn
      # @api private
      # Provides the implementation for `eql`.
      # Not intended to be instantiated directly.
      class Eql < BaseMatcher
        def failure_message
          "\nexpected: #{expected.inspect}\n     got: #{actual.inspect}\n\n(compared using eql?)\n"
        end

        def failure_message_when_negated
          "\nexpected: value != #{expected.inspect}\n     got: #{actual.inspect}\n\n(compared using eql?)\n"
        end

        def diffable?
          true
        end

      private

        def match(expected, actual)
          actual.eql? expected
        end
      end
    end
  end
end
