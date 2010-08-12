module RSpec
  module Core
    class CommandLine
      def initialize(options, configuration=RSpec::configuration, world=RSpec::world)
        if Array === options
          options = ConfigurationOptions.new(options)
          options.parse_options
        end
        @options       = options
        @configuration = configuration
        @world         = world
      end

      def run(err, out)
        @options.configure(@configuration)
        @configuration.error_stream = err
        @configuration.output_stream ||= out
        @configuration.load_spec_files
        @configuration.configure_mock_framework
        @world.announce_inclusion_filter
        @world.announce_exclusion_filter

        @configuration.reporter.report(example_count) do |reporter|
          begin
            @configuration.run_hook(:before, :suite)
            example_groups.run_examples(reporter)
          ensure
            @configuration.run_hook(:after, :suite)
          end
        end

        example_groups.success?
      end

    private

      def example_count
        @world.example_count
      end

      module ExampleGroups
        def run_examples(reporter)
          @success = self.inject(true) {|success, group| success &= group.run(reporter)}
        end

        def success?
          @success ||= false
        end
      end

      def example_groups
        @world.example_groups.extend(ExampleGroups)
      end
    end
  end
end
