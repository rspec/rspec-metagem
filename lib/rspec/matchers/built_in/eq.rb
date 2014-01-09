module RSpec
  module Matchers
    module BuiltIn
      class Eq < BaseMatcher
        def match(expected, actual)
          actual == expected
        end

        def failure_message
          "\nexpected: #{expected.inspect}\n     got: #{actual.inspect}\n\n(compared using ==)\n"
        end

        def failure_message_when_negated
          "\nexpected: value != #{expected.inspect}\n     got: #{actual.inspect}\n\n(compared using ==)\n"
        end

        def description
          "#{name_to_sentence} #{@expected.inspect}"
        end

        def diffable?; true; end
      end
    end
  end
end

