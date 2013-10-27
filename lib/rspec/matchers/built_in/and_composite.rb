module RSpec
  module Matchers
    module BuiltIn
      class AndComposite < Composite

        def matches?(actual)
          matchers.all? do |matcher|
            evaluated_matchers << matcher
            matcher.matches?(actual)
          end
        end

        def failure_message_for_should
          evaluated_matchers.map do |matcher|
            handle_matcher matcher
          end.join "\nand\n"
        end

        private

        def handle_matcher matcher
          matcher.failure_message_for_should
        end

      end
    end
  end
end
