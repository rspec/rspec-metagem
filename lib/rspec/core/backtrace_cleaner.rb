module RSpec
  module Core
    class BacktraceCleaner

      attr_accessor :include_patterns
      attr_accessor :exclude_patterns

      def initialize(include_patterns, exclude_patterns)
        @include_patterns = include_patterns
        @exclude_patterns = exclude_patterns
      end

      def include?(line)
        matches_an_include_pattern? line or not matches_a_exclude_pattern? line
      end

      private

      def matches_an_include_pattern?(line)
        @include_patterns.any? {|p| line =~ p}
      end

      def matches_a_exclude_pattern?(line)
        @exclude_patterns.any? {|p| line =~ p}
      end
    end
  end
end
