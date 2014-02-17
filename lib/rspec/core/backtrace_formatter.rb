module RSpec
  module Core
    class BacktraceFormatter
      # This is only used externally by rspec-expectations. Can be removed once
      # rspec-expectations uses
      # RSpec.configuration.backtrace_formatter.format_backtrace instead.
      def self.format_backtrace(backtrace, options = {})
        RSpec.configuration.backtrace_formatter.format_backtrace(backtrace, options)
      end

      attr_accessor :exclusion_patterns, :inclusion_patterns

      def initialize
        @full_backtrace = false
        @system_exclusion_patterns = [] << Regexp.union(
          *["/lib\d*/ruby/",
            "org/jruby/",
            "bin/",
            "/gems/",
            "lib/rspec/(core|expectations|matchers|mocks)"].
          map {|s| Regexp.new(s.gsub("/", File::SEPARATOR))})
        @exclusion_patterns = [] + @system_exclusion_patterns
        @inclusion_patterns = [Regexp.new(Dir.getwd)]
      end

      def full_backtrace=(full_backtrace)
        @full_backtrace = full_backtrace
      end

      def full_backtrace?
        @full_backtrace || @exclusion_patterns.empty?
      end

      def format_backtrace(backtrace, options = {})
        return backtrace if options[:full_backtrace]
        backtrace.
          take_while {|l| l != RSpec::Core::Runner::AT_EXIT_HOOK_BACKTRACE_LINE}.
          map        {|l| backtrace_line(l)}.
          compact.
          tap do |filtered|
            if filtered.empty?
              filtered.concat backtrace
              filtered << ""
              filtered << "  Showing full backtrace because every line was filtered out."
              filtered << "  See docs for RSpec::Configuration#backtrace_exclusion_patterns and"
              filtered << "  RSpec::Configuration#backtrace_inclusion_patterns for more information."
            end
          end
      end

      # @api private
      def backtrace_line(line)
        RSpec::Core::Metadata::relative_path(line) unless exclude?(line)
      rescue SecurityError
        nil
      end

      # @api private
      def exclude?(line)
        return false if @full_backtrace
        matches_an_exclusion_pattern?(line) &&
        doesnt_match_inclusion_pattern_unless_system_exclusion?(line)
      end

    private

      def matches_an_exclusion_pattern?(line)
        @exclusion_patterns.any? { |p| line =~ p }
      end

      def doesnt_match_inclusion_pattern_unless_system_exclusion?(line)
        @system_exclusion_patterns.any? { |p| line =~ p } || @inclusion_patterns.none? { |p| p =~ line }
      end

    end
  end
end
