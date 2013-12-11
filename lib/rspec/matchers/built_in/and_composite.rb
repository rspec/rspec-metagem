module RSpec
  module Matchers
    module BuiltIn
      class AndComposite < Composite

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
    end
  end
end
