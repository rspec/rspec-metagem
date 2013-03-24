module RSpec
  module Core
    class BacktraceCleaner

      DEFAULT_INCLUDE_PATTERNS = [Regexp.new(Dir.getwd)]
      DEFAULT_EXCLUDE_PATTERNS = [
        /\/lib\d*\/ruby\//,
        /org\/jruby\//,
        /bin\//,
        %r|/gems/|,
        /spec\/spec_helper\.rb/,
        /lib\/rspec\/(core|expectations|matchers|mocks)/
      ]

      attr_accessor :include_patterns
      attr_accessor :exclude_patterns

      def initialize(include_patterns=DEFAULT_INCLUDE_PATTERNS, exclude_patterns=DEFAULT_EXCLUDE_PATTERNS.dup)
        @include_patterns = include_patterns
        @exclude_patterns = exclude_patterns
      end

      def exclude?(line)
        @include_patterns.none? {|p| line =~ p} and @exclude_patterns.any? {|p| line =~ p}
      end

      def full_backtrace=(true_or_false)
        @exclude_patterns = true_or_false ? [] : DEFAULT_EXCLUDE_PATTERNS
      end
    end
  end
end
