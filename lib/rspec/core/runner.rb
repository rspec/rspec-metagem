require 'drb/drb'

module RSpec
  module Core
    class Runner

      def self.installed_at_exit?
        @installed_at_exit ||= false
      end

      def self.autorun
        return if installed_at_exit? || running_in_drb?
        @installed_at_exit = true
        at_exit { new.run(ARGV, $stderr, $stdout) ? exit(0) : exit(1) }
      end

      def self.running_in_drb?
        (DRb.current_server rescue false) &&
        !!((DRb.current_server.uri) =~ /druby\:\/\/127.0.0.1\:/)
      end

      def run(args, err, out)
        if args.any? {|a| %w[--drb -X].include? a}
          run_over_drb(args, err, out) || run_in_process(args, err, out)
        else
          run_in_process(args, err, out)
        end
      end

      def run_over_drb(args, err, out)
        DRbCommandLine.new(args).run(err, out)
      end

      def run_in_process(args, err, out)
        CommandLine.new(args).run(err, out)
      end

    end

    class DRbCommandLine
      def initialize(argv)
        @options = RSpec::Core::ConfigurationOptions.new(argv)
      end

      def run(err, out)
        begin
          begin
            DRb.start_service("druby://localhost:0")
          rescue SocketError, Errno::EADDRNOTAVAIL
            DRb.start_service("druby://:0")
          end
          spec_server = DRbObject.new_with_uri("druby://127.0.0.1:#{@options.drb_port}")
          spec_server.run(@options.to_drb_argv, err, out)
          true
        rescue DRb::DRbConnError
          err.puts "No DRb server is running. Running in local process instead ..."
          false
        end
      end
    end

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
