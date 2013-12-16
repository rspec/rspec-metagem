module RSpec
  module Matchers
    module BuiltIn
      class Satisfy
        include Composable

        def initialize(&block)
          @block = block
        end

        def matches?(actual, &block)
          @block = block if block
          @actual = actual
          @block.call(actual)
        end

        def failure_message
          "expected #{@actual} to satisfy block"
        end

        def failure_message_when_negated
          "expected #{@actual} not to satisfy block"
        end

        def description
          "satisfy block"
        end
      end
    end
  end
end
