module RSpec
  module Core
    class BacktraceCleaner

      DEFAULT_INCLUSION_PATTERNS = [Regexp.new(Dir.getwd)]
      DEFAULT_EXCLUSION_PATTERNS = [
        /\/lib\d*\/ruby\//,
        /org\/jruby\//,
        /bin\//,
        %r|/gems/|,
        /spec\/spec_helper\.rb/,
        /lib\/rspec\/(core|expectations|matchers|mocks)/
      ]

      attr_accessor :inclusion_patterns
      attr_accessor :exclusion_patterns

      def initialize(inclusion_patterns=DEFAULT_INCLUSION_PATTERNS.dup, exclusion_patterns=DEFAULT_EXCLUSION_PATTERNS.dup)
        @inclusion_patterns = inclusion_patterns
        @exclusion_patterns = exclusion_patterns
      end

      def exclude?(line)
        @inclusion_patterns.none? {|p| line =~ p} and @exclusion_patterns.any? {|p| line =~ p}
      end

      def full_backtrace=(true_or_false)
        @exclusion_patterns = true_or_false ? [] : DEFAULT_EXCLUSION_PATTERNS.dup
      end
    end
  end
end
