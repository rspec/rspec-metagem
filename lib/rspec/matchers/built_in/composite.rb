module RSpec
  module Matchers
    module BuiltIn
      class Composite < BaseMatcher

        attr_reader :type, :base_matcher, :new_matcher

        def initialize base_matcher, new_matcher, options = {}
          @type         = options.fetch(:type, :and)
          @base_matcher = base_matcher
          @new_matcher  = new_matcher
        end

        def matches?(actual)
          case type
          when :and
            base_matcher.matches?(actual) && new_matcher.matches?(actual)
          when :or
            base_matcher.matches?(actual) || new_matcher.matches?(actual)
          else
            raise ArgumentError
          end
        end

      end
    end
  end
end
