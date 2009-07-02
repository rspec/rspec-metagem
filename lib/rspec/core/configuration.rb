module Rspec
  module Core
    class Configuration
      # Regex patterns to scrub backtrace with
      attr_reader :backtrace_clean_patterns

      # All of the defined before/after blocks setup in the configuration
      attr_reader :before_and_afters

      # Allows you to control what examples are ran by filtering 
      attr_reader :filter

      attr_reader :exclusion_filter

      # Modules that will be included or extended based on given filters
      attr_reader :include_or_extend_modules

      # Run all examples if the run is filtered, and no examples were found.  Normally this is what you want -
      # when using focused examples for instance.  Defaults to true
      attr_accessor :run_all_when_everything_filtered

      # Enable profiling of example run - defaults to false
      attr_accessor :profile_examples

      # Enable verbose interal logging of the framework - defaults to false
      attr_accessor :trace

      attr_reader :mock_framework

      def initialize
        @backtrace_clean_patterns = [/\/lib\/ruby\//, /bin\/rcov:/, /vendor\/rails/, /bin\/rspec/, /bin\/spec/]
        @run_all_when_everything_filtered = true
        @trace = false
        @profile_examples = false
        @color_enabled = false
        @before_and_afters = { :before => { :each => [], :all => [] }, :after => { :each => [], :all => [] } }
        @include_or_extend_modules = []
        @formatter_to_use = Rspec::Core::Formatters::ProgressFormatter
        @filter, @exclusion_filter = nil, nil
        mock_with nil unless @mock_framework_established
      end

      # E.g. alias_example_to :crazy_slow, :speed => 'crazy_slow' defines
      # crazy_slow as an example variant that has the crazy_slow speed option
      def alias_example_to(new_name, extra_options={})
        Rspec::Core::ExampleGroup.alias_example_to(new_name, extra_options)
      end

      def cleaned_from_backtrace?(line)
        @backtrace_clean_patterns.any? { |regex| line =~ regex }
      end

      def mock_with(make_a_mockery_with=nil)
        @mock_framework_established = true
        @mock_framework = make_a_mockery_with
        mock_framework_class = case make_a_mockery_with.to_s
        when /mocha/i
          require 'rspec/core/mocking/with_mocha'
          Rspec::Core::Mocking::WithMocha
        when /rr/i
          require 'rspec/core/mocking/with_rr'
          Rspec::Core::Mocking::WithRR
        when /rspec/i
          require 'rspec/core/mocking/with_rspec'
          Rspec::Core::Mocking::WithRspec
        else
          require 'rspec/core/mocking/with_absolutely_nothing'
          Rspec::Core::Mocking::WithAbsolutelyNothing
        end 

        Rspec::Core::ExampleGroup.send(:include, mock_framework_class)
      end

      def autorun!
        Rspec::Core::Runner.autorun
      end

      # Turn ANSI on with 'true', or off with 'false'
      def color_enabled=(on_or_off)
        @color_enabled = on_or_off
      end

      # Output with ANSI color enabled? Defaults to false
      def color_enabled?
        @color_enabled
      end

      def filter_run(options={})
        @filter = options
      end

      def run_all_when_everything_filtered?
        @run_all_when_everything_filtered
      end

      def formatter=(formatter_to_use)
        @formatter_to_use = case formatter_to_use.to_s
        when 'documentation' then Rspec::Core::Formatters::DocumentationFormatter
        when 'progress' then Rspec::Core::Formatters::ProgressFormatter
        else raise(ArgumentError, "Formatter '#{formatter_to_use}' unknown - maybe you meant 'documentation' or 'progress'?.")
        end
      end

      # The formatter all output should use.  Defaults to the progress formatter
      def formatter
        @formatter ||= @formatter_to_use.new
      end

      # Where does output go? For now $stdout
      def output
        $stdout
      end

      # Output some string for debugging/tracing assistance if trace is enabled
      # The trace string should be sent as a block, which means it will only be interpolated if trace is actually enabled
      # We allow an override here so that trace can be set at lower levels (such as the describe or example level)
      def trace(override = false)
        raise(ArgumentError, "Must yield a block with your string to trace.") unless block_given?
        return unless trace? || override
        puts("[TRACE] #{yield}")
      end

      def puts(msg)
        output.puts(msg)    
      end

      # If true, Rspec will provide detailed trace output of its self as it runs.
      # Can be turned on at the global (configuration) level or at the individual behaviour (describe) level.
      def trace?
        @trace == true
      end

      def include(mod, options={})
        include_or_extend_modules << [:include, mod, options]
      end

      def extend(mod, options={})
        include_or_extend_modules << [:extend, mod, options]
      end

      def find_modules(group)
        include_or_extend_modules.select do |include_or_extend, mod, options|
          options.all? do |filter_on, filter|
            Rspec::Core.world.apply_condition(filter_on, filter, group.metadata)
          end
        end
      end

      def before(each_or_all=:each, options={}, &block)
        before_and_afters[:before][each_or_all] << [options, block]
      end

      def after(each_or_all=:each, options={}, &block)
        before_and_afters[:after][each_or_all] << [options, block]
      end

      def find_before_or_after(desired_before_or_after, desired_each_or_all, group)
        before_and_afters[desired_before_or_after][desired_each_or_all].select do |options, block|
          options.all? do |filter_on, filter|
            Rspec::Core.world.apply_condition(filter_on, filter, group.metadata)
          end
        end.map { |options, block| block }
      end

    end

  end
end
