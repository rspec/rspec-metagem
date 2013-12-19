module RSpec
  module Matchers
    module BuiltIn
      class MatchArray < BaseMatcher
        def match(expected, actual)
          return false unless actual.respond_to? :to_ary

          @extra_items = difference_between_arrays(actual, expected) do |a, e|
            values_match?(e, a)
          end

          @missing_items = difference_between_arrays(expected, actual) do |e, a|
            values_match?(e, a)
          end

          @extra_items.empty? & @missing_items.empty?
        end

        def failure_message
          if actual.respond_to? :to_ary
            message =  "expected collection contained:  #{safe_sort(surface_descriptions_in expected).inspect}\n"
            message += "actual collection contained:    #{safe_sort(actual).inspect}\n"
            message += "the missing elements were:      #{safe_sort(surface_descriptions_in @missing_items).inspect}\n" unless @missing_items.empty?
            message += "the extra elements were:        #{safe_sort(@extra_items).inspect}\n"   unless @extra_items.empty?
          else
            message = "expected an array, actual collection was #{actual.inspect}"
          end

          message
        end

        def failure_message_when_negated
          "`match_array` does not support negation"
        end

        def description
          "contain exactly #{_pretty_print(surface_descriptions_in expected)}"
        end

        private

        def safe_sort(array)
          array.sort rescue array
        end

        def difference_between_arrays(array_1, array_2)
          remaining = array_1.to_ary.dup

          array_2.to_ary.each do |e2|
            if index = remaining.index { |e1| yield e1, e2 }
              remaining.delete_at(index)
            end
          end

          remaining
        end
      end
    end
  end
end
