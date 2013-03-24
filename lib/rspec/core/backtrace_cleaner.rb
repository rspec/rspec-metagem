module RSpec
  module Core
    class BacktraceCleaner

      attr_accessor :include_patterns
      attr_accessor :discard_patterns

      def initialize(include_patterns, discard_patterns)
        @include_patterns = include_patterns
        @discard_patterns = discard_patterns
      end

      def include?(line)
        matches_an_include_pattern? line or not matches_a_discard_pattern? line
      end

      private

      def matches_an_include_pattern?(line)
        @include_patterns.any? {|p| line =~ p}
      end

      def matches_a_discard_pattern?(line)
        @discard_patterns.any? {|p| line =~ p}
      end
    end
  end
end
