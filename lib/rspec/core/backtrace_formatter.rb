module RSpec
  module Core
    # @private
    class BacktraceFormatter
      # @private
      attr_accessor :exclusion_patterns, :inclusion_patterns

      def initialize
        @full_backtrace = false

        patterns = %w[ /lib\d*/ruby/ bin/ exe/rspec ]
        patterns << "org/jruby/" if RUBY_PLATFORM == 'java'
        patterns.map! { |s| Regexp.new(s.gsub("/", File::SEPARATOR)) }

        @system_exclusion_patterns = [Regexp.union(RSpec::CallerFilter::IGNORE_REGEX, *patterns)]
        @exclusion_patterns = [] + @system_exclusion_patterns
        @inclusion_patterns = [Regexp.new(Dir.getwd)]
      end

      attr_writer :full_backtrace

      def full_backtrace?
        @full_backtrace || @exclusion_patterns.empty?
      end

      def filter_gem(gem_name)
        sep = File::SEPARATOR
        pattern = /#{sep}#{gem_name}(-[^#{sep}]+)?#{sep}/

        @exclusion_patterns        << pattern
        @system_exclusion_patterns << pattern
      end

      def format_backtrace(backtrace, options={})
        return backtrace if options[:full_backtrace]

        backtrace.map { |l| backtrace_line(l) }.compact.
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

      def backtrace_line(line)
        Metadata.relative_path(line) unless exclude?(line)
      rescue SecurityError
        nil
      end

      def exclude?(line)
        return false if @full_backtrace
        relative_line = Metadata.relative_path(line)
        return false unless matches?(@exclusion_patterns, relative_line)
        matches?(@system_exclusion_patterns, relative_line) || !matches?(@inclusion_patterns, line)
      end

    private

      def matches?(patterns, line)
        patterns.any? { |p| line =~ p }
      end
    end
  end
end
