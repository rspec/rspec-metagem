module RSpec
  module Matchers
    module BuiltIn
      class Compound < BaseMatcher

        attr_reader :matchers, :evaluated_matchers

        def initialize(*matchers)
          raise ArgumentError, 'two or more matchers should be provided' unless matchers.size >= 2
          @matchers = matchers
          @evaluated_matchers = []
        end

        def does_not_match?(actual)
          false
        end

        def failure_message_when_negated
          "`chained matchers` does not support negation"
        end

        class And < self
          def match(expected, actual)
            matchers.all? do |matcher|
              evaluated_matchers << matcher
              matcher.matches?(actual)
            end
          end

          def failure_message
            evaluated_matchers.map do |matcher|
              handle_matcher matcher
            end.join "\nand\n"
          end

          private

          def handle_matcher matcher
            matcher.failure_message
          end

          def negative_failure_message_from matcher
            message ||= matcher.respond_to?(:failure_message_for_should_not) ?
                        matcher.failure_message_for_should_not :
                        matcher.negative_failure_message
          end
        end

        class Or < self
          def matches?(actual)
            matchers.any? do |matcher|
              evaluated_matchers << matcher
              matcher.matches? actual
            end
          end
        end
      end
    end
  end
end
