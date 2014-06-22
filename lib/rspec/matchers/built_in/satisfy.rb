module RSpec
  module Matchers
    module BuiltIn
      # @api private
      # Provides the implementation for `satisfy`.
      # Not intended to be instantiated directly.
      class Satisfy < BaseMatcher
        def initialize(&block)
          @block = block
        end

        # @private
        def matches?(actual, &block)
          @block = block if block
          @actual = actual
          @block.call(actual)
        end

        # @api private
        # @return [String]
        def failure_message
          "expected #{@actual} to satisfy block"
        end

        # @api private
        # @return [String]
        def failure_message_when_negated
          "expected #{@actual} not to satisfy block"
        end

        # @api private
        # @return [String]
        def description
          "satisfy block"
        end
      end
    end
  end
end
