module RSpec
  module Matchers
    module BuiltIn
      class Include < BaseMatcher
        def initialize(*expected)
          @expected = expected
        end

        def matches?(actual)
          @actual = actual
          perform_match(:all?, :all?, @actual, @expected)
        end

        def does_not_match?(actual)
          @actual = actual
          perform_match(:none?, :any?, @actual, @expected)
        end

        def description
          "include#{expected_to_sentence}"
        end

        def diffable?
          # Matchers do not diff well, since diff uses their inspect
          # output, which includes their instance variables and such.
          @expected.none? { |e| is_a_matcher?(e) }
        end

        private

        def perform_match(predicate, hash_predicate, actuals, expecteds)
          expecteds.__send__(predicate) do |expected|
            if comparing_hash_values?(actuals, expected)
              expected.__send__(hash_predicate) { |k,v|
                actuals.has_key?(k) && actuals[k] == v
              }
            elsif comparing_hash_keys?(actuals, expected)
              actuals.has_key?(expected)
            elsif comparing_with_matcher?(actual, expected)
              actual.any? { |value| expected.matches?(value) }
            else
              actuals.include?(expected)
            end
          end
        end

        def comparing_hash_keys?(actual, expected)
          actual.is_a?(Hash) && !expected.is_a?(Hash)
        end

        def comparing_hash_values?(actual, expected)
          actual.is_a?(Hash) && expected.is_a?(Hash)
        end

        def comparing_with_matcher?(actual, expected)
          actual.is_a?(Array) && is_a_matcher?(expected)
        end

        def is_a_matcher?(object)
          return false if object.respond_to?(:i_respond_to_everything_so_im_not_really_a_matcher)

          [:failure_message_for_should, :failure_message].any? do |msg|
            object.respond_to?(msg)
          end && object.respond_to?(:matches?)
        end
      end
    end
  end
end
