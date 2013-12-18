module RSpec
  module Matchers
    module BuiltIn
      class Include < BaseMatcher
        def initialize(*expected)
          @expected = expected
        end

        def matches?(actual)
          @actual = actual
          perform_match(:all?, :all?)
        end

        def does_not_match?(actual)
          @actual = actual
          perform_match(:none?, :any?)
        end

        def description
          "include#{expected_to_sentence}"
        end

        def failure_message
          improve_hash_formatting(super)
        end

        def failure_message_when_negated
          improve_hash_formatting(super)
        end

        def diffable?
          # Matchers do not diff well, since diff uses their inspect
          # output, which includes their instance variables and such.
          expected.none? { |e| RSpec::Matchers.is_a_matcher?(e) }
        end

        private

        def perform_match(predicate, hash_predicate)
          expected.__send__(predicate) do |expected_item|
            if comparing_hash_values?(expected_item)
              expected_item.__send__(hash_predicate) { |k,v|
                actual.has_key?(k) && actual[k] == v
              }
            elsif comparing_hash_keys?(expected_item)
              actual.has_key?(expected_item)
            elsif comparing_with_matcher?(expected_item)
              actual.any? { |value| expected_item.matches?(value) }
            else
              actual.include?(expected_item)
            end
          end
        end

        def comparing_hash_keys?(expected_item)
          actual.is_a?(Hash) && !expected_item.is_a?(Hash)
        end

        def comparing_hash_values?(expected_item)
          actual.is_a?(Hash) && expected_item.is_a?(Hash)
        end

        def comparing_with_matcher?(expected_item)
          actual.is_a?(Array) && RSpec::Matchers.is_a_matcher?(expected_item)
        end
      end
    end
  end
end
