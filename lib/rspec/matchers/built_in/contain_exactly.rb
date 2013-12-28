module RSpec
  module Matchers
    module BuiltIn
      class ContainExactly < BaseMatcher
        def match(expected, actual)
          return false unless actual_is_a_collection?
          @actual = actual.to_a
          extra_items.empty? && missing_items.empty?
        end

        def failure_message
          if actual_is_a_collection?
            message  = "expected collection contained:  #{safe_sort(surface_descriptions_in expected).inspect}\n"
            message += "actual collection contained:    #{safe_sort(actual).inspect}\n"
            message += "the missing elements were:      #{safe_sort(surface_descriptions_in missing_items).inspect}\n" unless missing_items.empty?
            message += "the extra elements were:        #{safe_sort(extra_items).inspect}\n" unless extra_items.empty?
            message
          else
            "expected a collection that can be converted to an array with `#to_a`, but got #{actual.inspect}"
          end
        end

        def failure_message_when_negated
          "`contain_exactly` does not support negation"
        end

        def description
          "contain exactly #{_pretty_print(surface_descriptions_in expected)}"
        end

      private

        def actual_is_a_collection?
          enumerable?(actual) && actual.respond_to?(:to_a)
        end

        def safe_sort(array)
          array.sort rescue array
        end

        def missing_items
          @missing_items ||= best_solution.unmatched_expected_indexes.map do |index|
            expected[index]
          end
        end

        def extra_items
          @extra_items ||= best_solution.unmatched_actual_indexes.map do |index|
            actual[index]
          end
        end

        def best_solution
          @best_solution ||= pairings_maximizer.find_best_solution
        end

        def pairings_maximizer
          @pairings_maximizer ||= begin
            expected_matches = Array.new(expected.count) { [] }
            actual_matches   = Array.new(actual.count)   { [] }

            expected.each_with_index do |e, ei|
              actual.each_with_index do |a, ai|
                if values_match?(e, a)
                  expected_matches[ei] << ai
                  actual_matches[ai] << ei
                end
              end
            end

            PairingsMaximizer.new(expected_matches, actual_matches)
          end
        end

        class PairingsMaximizer
          attr_reader :expected_to_actual_matched_indexes,
                      :actual_to_expected_matched_indexes,
                      :unmatched_expected_indexes,
                      :unmatched_actual_indexes,
                      :indeterminite_expected_indexes,
                      :indeterminite_actual_indexes

          def initialize(expected_to_actual_matched_indexes, actual_to_expected_matched_indexes)
            @expected_to_actual_matched_indexes = expected_to_actual_matched_indexes
            @actual_to_expected_matched_indexes = actual_to_expected_matched_indexes

            categorize_indexes(expected_to_actual_matched_indexes,
                               actual_to_expected_matched_indexes,
                               @unmatched_expected_indexes     = [],
                               @indeterminite_expected_indexes = [])

            categorize_indexes(actual_to_expected_matched_indexes,
                               expected_to_actual_matched_indexes,
                               @unmatched_actual_indexes     = [],
                               @indeterminite_actual_indexes = [])
          end

          def find_best_solution
            return self if candidate_result?
            best_solution_so_far = NullSolution

            expected_index = indeterminite_expected_indexes.first
            actuals = expected_to_actual_matched_indexes[expected_index]

            actuals.each do |actual_index|
              result = try_pairing(expected_index, actual_index)
              return result if result.ideal_result?
              best_solution_so_far = result if result.better_candidate_than?(best_solution_so_far)
            end

            best_solution_so_far
          end

          def better_candidate_than?(other)
            return false unless candidate_result?
            unmatched_item_count < other.unmatched_item_count
          end

          NullSolution = Class.new do
            INFINITY = 1 / 0.0
            def self.unmatched_item_count; INFINITY; end
          end

          # A result is only a candidate solution if there are no
          # expected or actual items that are indeterminite.
          def candidate_result?
            indeterminite_expected_indexes.empty? &&
            indeterminite_actual_indexes.empty?
          end

          def ideal_result?
            candidate_result? && (
              unmatched_expected_indexes.empty? ||
              unmatched_actual_indexes.empty?
            )
          end

          def unmatched_item_count
            unmatched_expected_indexes.count + unmatched_actual_indexes.count
          end

        private

          def categorize_indexes(indexes_to_categorize, other_indexes, unmatched, indeterminite)
            indexes_to_categorize.each_with_index do |matches, index|
              if matches.empty?
                unmatched << index
              elsif !reciprocal_single_match?(matches, index, other_indexes)
                indeterminite << index
              end
            end
          end

          def reciprocal_single_match?(matches, index, other_list)
            return false unless matches.one?
            other_list[matches.first] == [index]
          end

          def try_pairing(expected_index, actual_index)
            modified_expecteds = apply_pairing_to(expected_to_actual_matched_indexes, expected_index, actual_index)
            modified_actuals   = apply_pairing_to(actual_to_expected_matched_indexes, actual_index, expected_index)

            self.class.new(modified_expecteds, modified_actuals).find_best_solution
          end

          def apply_pairing_to(original_matches, this_list_index, other_list_index)
            original_matches.each_with_index.map do |matches, index|
              if index == this_list_index
                [other_list_index]
              else
                matches - [other_list_index]
              end
            end
          end
        end
      end
    end
  end
end
