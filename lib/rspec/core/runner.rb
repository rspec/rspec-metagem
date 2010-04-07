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
        
        reporter.report(example_count) do |reporter|
          example_groups.run_all(reporter)
        end
        
        example_groups.success?
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
        Rspec::Core.world.example_groups_to_run.extend(ExampleGroups)
      end

      module ExampleGroups
        def run_all(reporter)
          @success = self.inject(true) {|success, group| success &= group.run(reporter)}
        end

        def success?
          @success ||= false
        end
      end
      
    end

  end
end
