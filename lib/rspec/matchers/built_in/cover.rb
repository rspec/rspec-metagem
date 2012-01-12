module RSpec
  module Matchers
    module BuiltIn
      class Cover
        include BaseMatcher

        def initialize(*expected)
          super(expected)
        end

        def matches?(range)
          expected.all? {|e| super(range).cover?(e)}
        end

        def does_not_match?(range)
          @actual = range
          expected.none? {|e| range.cover?(e)}
        end
      end
    end
  end
end
