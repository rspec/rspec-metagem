module RSpec
  module Core
    class CommandLine
      def initialize(argv)
        @options = RSpec::Core::ConfigurationOptions.new(argv)
        @options.configure(configuration)
        configuration.require_files_to_run
        configuration.configure_mock_framework
      end

      def run(err, out)
        configuration.error_stream = err
        configuration.output_stream = out
        world.announce_inclusion_filter

        configuration.formatter.report(world.example_count) do |reporter|
          example_groups.run_examples(reporter)
        end
        
        example_groups.success?
      end

    private

      def example_count
        world.example_count
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
        world.example_groups.extend(ExampleGroups)
      end

      def configuration
        RSpec.configuration
      end

      def world
        RSpec.world
      end
    end
  end
end
