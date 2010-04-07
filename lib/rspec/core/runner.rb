module Rspec
  module Core

    class Runner

      def self.installed_at_exit?
        @installed_at_exit ||= false
      end

      def self.autorun
        return if installed_at_exit?
        @installed_at_exit = true
        at_exit { new.run(ARGV) ? exit(0) : exit(1) } 
      end

      def configuration
        Rspec.configuration
      end

      def reporter
        configuration.formatter
      end

      def run(args = [])
        configure(args)
        
        reporter.report(example_count) do
          example_groups.inject(true) do |success, example_group|
            success &= example_group.run(reporter)
          end
        end
      end
      
    private

      def configure(args)
        Rspec::Core::CommandLineOptions.parse(args).apply(configuration)
        configuration.require_all_files
        configuration.configure_mock_framework
      end

      def example_count
        Rspec::Core.world.total_examples_to_run
      end

      def example_groups
        Rspec::Core.world.example_groups_to_run
      end
      
    end

  end
end
