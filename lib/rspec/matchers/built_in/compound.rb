module RSpec
  module Matchers
    module BuiltIn
      # @api private
      # Base class for `and` and `or` compound matchers.
      class Compound < BaseMatcher
        # @private
        attr_reader :matcher_1, :matcher_2

        def initialize(matcher_1, matcher_2)
          @matcher_1 = matcher_1
          @matcher_2 = matcher_2
        end

        # @private
        def does_not_match?(_actual)
          raise NotImplementedError, "`expect(...).not_to " \
            "matcher.#{conjunction} matcher` is not supported"
        end

        # @api private
        # @return [String]
        def description
          singleline_message(matcher_1.description, matcher_2.description)
        end

      private

        def initialize_copy(other)
          @matcher_1 = @matcher_1.clone
          @matcher_2 = @matcher_2.clone
          super
        end

        def indent_multiline_message(message)
          message.lines.map do |line|
            line =~ /\S/ ? '   ' + line : line
          end.join
        end

        def compound_failure_message
          message_1 = matcher_1.failure_message
          message_2 = matcher_2.failure_message

          if multiline?(message_1) || multiline?(message_2)
            multiline_message(message_1, message_2)
          else
            singleline_message(message_1, message_2)
          end
        end

        def multiline_message(message_1, message_2)
          [
            indent_multiline_message(message_1.sub(/\n+\z/, '')),
            "...#{conjunction}:",
            indent_multiline_message(message_2.sub(/\A\n+/, ''))
          ].join("\n\n")
        end

        def multiline?(message)
          message.lines.count > 1
        end

        def singleline_message(message_1, message_2)
          [message_1, conjunction, message_2].join(' ')
        end

        # @api public
        # Matcher used to represent a compound `and` expectation.
        class And < self
          # @api private
          # @return [String]
          def failure_message
            if @matcher_1_matches
              matcher_2.failure_message
            elsif @matcher_2_matches
              matcher_1.failure_message
            else
              compound_failure_message
            end
          end

        private

          def match(_expected, actual)
            @matcher_1_matches = matcher_1.matches?(actual)
            @matcher_2_matches = matcher_2.matches?(actual)

            @matcher_1_matches && @matcher_2_matches
          end

          def conjunction
            "and"
          end
        end

        # @api public
        # Matcher used to represent a compound `or` expectation.
        class Or < self
          # @api private
          # @return [String]
          def failure_message
            compound_failure_message
          end

        private

          def match(_expected, actual)
            matcher_1.matches?(actual) || matcher_2.matches?(actual)
          end

          def conjunction
            "or"
          end
        end
      end
    end
  end
end
