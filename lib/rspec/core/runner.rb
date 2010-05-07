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

      def inclusion_filter
        Rspec.configuration.filter
      end

      def run(args = [])
        configure(args)
        announce_inclusion_filter

        reporter.report(example_count) do |reporter|
          example_groups.run_examples(reporter)
        end
        
        example_groups.success?
      end
      
    private

      def announce_inclusion_filter
        if inclusion_filter
          if Rspec.configuration.run_all_when_everything_filtered? && Rspec::Core.world.example_count == 0
            Rspec.configuration.puts "No examples were matched by #{inclusion_filter.inspect}, running all"
            Rspec.configuration.clear_inclusion_filter
          else
            Rspec.configuration.puts "Run filtered using #{inclusion_filter.inspect}"          
          end
        end      
      end

      def configure(args)
        Rspec::Core::ConfigurationOptions.new(args).apply_to(configuration)
        configuration.require_files_to_run
        configuration.configure_mock_framework
      end

      def example_count
        Rspec::Core.world.example_count
      end

      def example_groups
        Rspec::Core.world.example_groups.extend(ExampleGroups)
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
