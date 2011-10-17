module RSpec
  module Matchers
    # Used _internally_ as a base class for matchers that ship with
    # rspec-expectations.
    #
    # == Warning
    #
    # This class is for internal use, and subject to change without notice.  We
    # strongly recommend that you do not base your custom matchers on this
    # class. If/when this changes, we will announce it and remove this warning.
    class Include < BaseMatcher
      def initialize(*expected)
        super(expected)
      end

      def matches?(actual)
        @actual = actual
        perform_match(:all?, :all?, actual, expected)
      end

      def does_not_match?(actual)
        @actual = actual
        perform_match(:none?, :any?, actual, expected)
      end

      def diffable?
        false
      end

      def description
        "include#{expected_to_sentence}"
      end

      def perform_match(predicate, hash_predicate, actual, expected)
        expected.send(predicate) do |expected|
          if comparing_hash_values?(actual, expected)
            expected.send(hash_predicate) {|k,v| actual[k] == v}
          elsif comparing_hash_keys?(actual, expected)
            actual.has_key?(expected)
          else
            actual.include?(expected)
          end
        end
      end

      def comparing_hash_keys?(actual, expected)
        actual.is_a?(Hash) && !expected.is_a?(Hash)
      end

      def comparing_hash_values?(actual, expected)
        actual.is_a?(Hash) && expected.is_a?(Hash)
      end
    end
  end
end
