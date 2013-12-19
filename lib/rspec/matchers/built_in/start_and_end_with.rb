module RSpec
  module Matchers
    module BuiltIn
      class StartAndEndWith < BaseMatcher
        def initialize(*expected)
          @expected = expected.length == 1 ? expected.first : expected
        end

        def matches?(actual)
          @actual = actual
          raise invalid_actual_object unless actual.respond_to?(:[])

          begin
            return subset_matches? if expected.respond_to?(:length)
            element_matches?
          rescue ArgumentError
            raise actual_is_unordered
          end
        end

      private

        def invalid_actual_object
          ArgumentError.new("#{actual.inspect} does not respond to :[]")
        end

        def actual_is_unordered
          ArgumentError.new("#{actual.inspect} does not have ordered elements")
        end
      end

      class StartWith < StartAndEndWith
        private

        def subset_matches?
          values_match?(expected, actual[0, expected.length])
        end

        def element_matches?
          values_match?(expected, actual[0])
        end
      end

      class EndWith < StartAndEndWith
        private

        def subset_matches?
          values_match?(expected, actual[-expected.length, expected.length])
        end

        def element_matches?
          values_match?(expected, actual[-1])
        end
      end
    end
  end
end
