module RSpec
  module Core
    class BacktraceCleaner

      attr_accessor :include_patterns
      attr_accessor :exclude_patterns

      def initialize(include_patterns, exclude_patterns)
        @include_patterns = include_patterns
        @exclude_patterns = exclude_patterns
      end

      def exclude?(line)
        @include_patterns.none? {|p| line =~ p} and @exclude_patterns.any? {|p| line =~ p}
      end
    end
  end
end
