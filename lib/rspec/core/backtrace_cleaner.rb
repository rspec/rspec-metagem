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
        if @include_patterns.any? {|p| line =~ p}
          return true
        else
          return not(@discard_patterns.any? {|p| line =~ p})
        end
      end
    end
  end
end
