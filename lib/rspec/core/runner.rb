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

      def require_all_files(configuration)
        configuration.files_to_run.map {|f| require f }
      end
      
      def run(args = [])
        Rspec::Core::CommandLineOptions.parse(args).apply(configuration)

        require_all_files(configuration)
        
        total_examples_to_run = Rspec::Core.world.total_examples_to_run

        old_sync, reporter.output.sync = reporter.output.sync, true if reporter.output.respond_to?(:sync=)

        suite_success = true

        reporter_supports_sync = reporter.output.respond_to?(:sync=)
        old_sync, reporter.output.sync = reporter.output.sync, true if reporter_supports_sync

        reporter.start(total_examples_to_run) # start the clock
        start = Time.now

        Rspec::Core.world.example_groups_to_run.each do |example_group|
          suite_success &= example_group.run(reporter)
        end

        reporter.start_dump(Time.now - start)

        reporter.dump_failures
        reporter.dump_summary
        reporter.dump_pending
        reporter.close

        reporter.output.sync = old_sync if reporter_supports_sync

        suite_success
      end
      

    end

  end
end
