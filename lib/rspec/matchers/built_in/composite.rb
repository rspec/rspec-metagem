module RSpec
  module Matchers
    module BuiltIn
      class Composite < BaseMatcher

        attr_reader :base_matcher, :new_matcher

        def initialize base_matcher, new_matcher
          @base_matcher = base_matcher
          @new_matcher  = new_matcher
        end

        def matches?(actual)
          base_matcher.matches?(actual) and new_matcher.matches?(actual)
        end

      end
    end
  end
end
