module RSpec
  module Matchers
    class Include
      include BaseMatcher

      def initialize(*expected)
        super(expected)
      end

      def matches?(actual)
        perform_match(:all?, :all?, super(actual), expected)
      end

      def does_not_match?(actual)
        @actual = actual
        perform_match(:none?, :any?, actual, expected)
      end

      def description
        "include#{expected_to_sentence}"
      end

      def diffable?
        true
      end

    private

      def perform_match(predicate, hash_predicate, actuals, expecteds)
        expecteds.send(predicate) do |expected|
          if comparing_hash_values?(actuals, expected)
            expected.send(hash_predicate) {|k,v| actuals[k] == v}
          elsif comparing_hash_keys?(actuals, expected)
            actuals.has_key?(expected)
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
    end

    # Passes if actual includes expected. This works for
    # collections and Strings. You can also pass in multiple args
    # and it will only pass if all args are found in collection.
    #
    # @example
    #
    #   [1,2,3].should include(3)
    #   [1,2,3].should include(2,3) #would pass
    #   [1,2,3].should include(2,3,4) #would fail
    #   [1,2,3].should_not include(4)
    #   "spread".should include("read")
    #   "spread".should_not include("red")
    def include(*expected)
      Include.new(*expected)
    end
  end
end
