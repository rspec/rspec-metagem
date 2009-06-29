module Rspec
  module Core

    class Runner

      def self.installed_at_exit?
        @installed_at_exit ||= false
      end

      def self.autorun
        return if installed_at_exit?
        @installed_at_exit = true
        at_exit { Rspec::Core::Runner.new.run(ARGV) ? exit(0) : exit(1) } 
      end

      def configuration
        Rspec::Core.configuration
      end

      def formatter
        Rspec::Core.configuration.formatter
      end

      def require_all_behaviours(files_from_args=[])
        files_from_args.each { |file| require file }
      end

      def run(args = [])
        require_all_behaviours(args)

        total_examples_to_run = Rspec::Core.world.total_examples_to_run

        old_sync, formatter.output.sync = formatter.output.sync, true if formatter.output.respond_to?(:sync=)

        suite_success = true

        formatter_supports_sync = formatter.output.respond_to?(:sync=)
        old_sync, formatter.output.sync = formatter.output.sync, true if formatter_supports_sync

        formatter.start(total_examples_to_run) # start the clock
        start = Time.now

        Rspec::Core.world.behaviours_to_run.each do |behaviour|
          suite_success &= behaviour.run(formatter)
        end

        formatter.start_dump(Time.now - start)

        formatter.dump_failures
        formatter.dump_summary
        formatter.dump_pending
        formatter.close

        formatter.output.sync = old_sync if formatter_supports_sync

        suite_success
      end

    end

  end
end