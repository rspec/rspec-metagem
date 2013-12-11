module RSpec
  module Matchers
    module BuiltIn
      class Composite < BaseMatcher

        attr_reader :matchers, :evaluated_matchers

        def initialize(*matchers)
          raise ArgumentError, 'two or more matchers should be provided' unless matchers.size >= 2
          @matchers = matchers
          @evaluated_matchers = []
        end

        def matches?(actual)
          raise NoMethodError, 'This matcher is not intended to be used directly.'
        end

        def failure_message_when_negated
          "`chained matchers` does not support negation"
        end

      end
    end
  end
end
