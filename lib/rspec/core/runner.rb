module RSpec
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
        RSpec.configuration
      end

      def reporter
        configuration.formatter
      end

      def inclusion_filter
        RSpec.configuration.filter
      end

      def run(args = [])
        configure(args)
        RSpec.world.announce_inclusion_filter

        reporter.report(example_count) do |reporter|
          example_groups.run_examples(reporter)
        end
        
        example_groups.success?
      end
      
    private

      def configure(args)
        RSpec::Core::ConfigurationOptions.new(args).apply_to(configuration)
        configuration.require_files_to_run
        configuration.configure_mock_framework
      end

      def example_count
        RSpec.world.example_count
      end

      def example_groups
        RSpec.world.example_groups.extend(ExampleGroups)
      end

      module ExampleGroups
        def run_examples(reporter)
          @success = self.inject(true) {|success, group| success &= group.run(reporter)}
        end

        def success?
          @success ||= false
        end
      end
      
    end
  end
end
