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
        options = configure(args)

        configuration.error_stream  = err
        configuration.output_stream = out

        if options.drb?
          run_over_drb(options, err, out) || 
          run_in_process(configuration, err, out)
        else
          run_in_process(configuration, err, out)
        end
      end

      def run_over_drb(options, err, out)
        DRbProxy.new(:argv => options.to_drb_argv, :remote_port => options.drb_port || ENV['RSPEC_DRB'].to_i).run(err, out)
      end

      def run_in_process(configuration, err, out)
        InProcess.new(configuration).run(err, out)
      end

    private

      # TODO - this method violates command/query, and the query has little to
      # do with the command
      def configure(args)
        options = RSpec::Core::ConfigurationOptions.new(args)
        options.configure(configuration)
        configuration.require_files_to_run
        configuration.configure_mock_framework
        options
      end

      class DRbProxy
        def initialize(options)
          @options = options
        end

        def run(err, out)
          begin
            begin
              DRb.start_service("druby://localhost:0")
            rescue SocketError, Errno::EADDRNOTAVAIL
              DRb.start_service("druby://:0")
            end
            spec_server = DRbObject.new_with_uri("druby://127.0.0.1:#{@options[:remote_port]}")
            spec_server.run(@options[:argv], err, out)
            true
          rescue DRb::DRbConnError
            err.puts "No DRb server is running. Running in local process instead ..."
            false
          end
        end
      end

      class InProcess
        attr_reader :configuration

        def initialize(configuration)
          @configuration = configuration
        end

        def run(err, out)
          RSpec.world.announce_inclusion_filter

          configuration.formatter.report(RSpec.world.example_count) do |reporter|
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
