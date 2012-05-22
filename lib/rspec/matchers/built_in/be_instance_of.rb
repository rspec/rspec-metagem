module RSpec
  module Matchers
    module BuiltIn
      class BeAnInstanceOf
        include BaseMatcher

        def initialize(expected)
          @expected = expected
        end

        def matches?(actual)
          @actual = actual
          @actual.instance_of? @expected
        end
      end
    end
  end
end
