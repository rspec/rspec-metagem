module RSpec
  module Matchers
    module BuiltIn
      class Compound < BaseMatcher
        attr_reader :matcher_1, :matcher_2

        def initialize(matcher_1, matcher_2)
          @matcher_1 = matcher_1
          @matcher_2 = matcher_2
        end

        def does_not_match?(actual)
          false
        end

        def failure_message_when_negated
          "`chained matchers` does not support negation"
        end

        def description
          singleline_message(matcher_1.description, super, matcher_2.description)
        end

      private

        def indent_multiline_message(message)
          message.lines.map do |line|
            line =~ /\S/ ? '   ' + line : line
          end.join
        end

        def compound_failure_message(conjunction)
          message_1 = matcher_1.failure_message
          message_2 = matcher_2.failure_message

          if multiline?(message_1) || multiline?(message_2)
            multiline_message(message_1, conjunction, message_2)
          else
            singleline_message(message_1, conjunction, message_2)
          end
        end

        def multiline_message(message_1, conjunction, message_2)
          [
            indent_multiline_message(message_1.rstrip),
            "...#{conjunction}:",
            indent_multiline_message(message_2.lstrip)
          ].join("\n\n")
        end

        def multiline?(message)
          message.lines.count > 1
        end

        def singleline_message(message_1, conjunction, message_2)
          [message_1, conjunction, message_2].join(' ')
        end

        class And < self
          def match(expected, actual)
            @matcher_1_matches = matcher_1.matches?(actual)
            @matcher_2_matches = matcher_2.matches?(actual)

            @matcher_1_matches && @matcher_2_matches
          end

          def failure_message
            if @matcher_1_matches
              matcher_2.failure_message
            elsif @matcher_2_matches
              matcher_1.failure_message
            else
              compound_failure_message("and")
            end
          end
        end

        class Or < self
          def match(expected, actual)
            matcher_1.matches?(actual) || matcher_2.matches?(actual)
          end

          def failure_message
            compound_failure_message("or")
          end
        end
      end
    end
  end
end

