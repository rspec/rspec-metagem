module RSpec
  module Core
    class BacktraceCleaner
      attr_accessor :exclusion_patterns, :inclusion_patterns

      def initialize
        @full_backtrace = false
        @exclusion_patterns = [
          /\/lib\d*\/ruby\//,
          /org\/jruby\//,
          /bin\//,
          %r|/gems/|,
          /spec\/spec_helper\.rb/,
          /lib\/rspec\/(core|expectations|matchers|mocks)/
        ]
        @inclusion_patterns = [Regexp.new(Dir.getwd)]
      end

      def exclude?(line)
        !@full_backtrace &&
          @exclusion_patterns.any?  {|p| p =~ line} &&
          @inclusion_patterns.none? {|p| p =~ line}
      end

      def full_backtrace=(full_backtrace)
        @full_backtrace = full_backtrace
      end

      def full_backtrace?
        @full_backtrace || @exclusion_patterns.empty?
      end
    end
  end
end
