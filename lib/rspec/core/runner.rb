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
        (DRb.current_server.uri rescue "") =~ /druby\:\/\/127.0.0.1\:/
      end

      def configuration
        RSpec.configuration
      end

      def run(args, err, out)
        if args.any? {|a| %w[--drb -X].include? a}
          run_over_drb(args, err, out) || 
          run_in_process(args, err, out)
        else
          run_in_process(args, err, out)
        end
      end

      def run_over_drb(args, err, out)
        DRbProxy.new(args).run(err, out)
      end

      def run_in_process(args, err, out)
        InProcess.new(args).run(err, out)
      end

    private

      class Worker
        def initialize(argv)
          drb = argv.any? {|a| %w[--drb -X].include? a}
          @options = RSpec::Core::ConfigurationOptions.new(argv)
          @options.configure(configuration)
          unless drb
            configuration.require_files_to_run
            configuration.configure_mock_framework
          end
        end

        def configuration
          RSpec.configuration
        end

        def run(err, out)
          configuration.error_stream = err
          configuration.output_stream = out
        end
      end

      class DRbProxy < Worker
        def run(err, out)
          super(err, out)
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

      class InProcess < Worker
        def run(err, out)
          super(err, out)
          RSpec.world.announce_inclusion_filter

          RSpec.configuration.formatter.report(RSpec.world.example_count) do |reporter|
            example_groups.run_examples(reporter)
          end
          
          example_groups.success?
        end

        def example_count
          RSpec.world.example_count
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
          RSpec.world.example_groups.extend(ExampleGroups)
        end
      end

    end
  end
end
