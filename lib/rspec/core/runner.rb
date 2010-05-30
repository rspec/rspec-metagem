require 'drb/drb'

module RSpec
  module Core
    class Runner

      def self.installed_at_exit?
        @installed_at_exit ||= false
      end

      def self.autorun
        return if installed_at_exit?
        @installed_at_exit = true
        at_exit { new.run(ARGV, $stderr, $stdout) ? exit(0) : exit(1) }
      end

      def configuration
        RSpec.configuration
      end

      def run(args, err, out)
        options = configure(args)

        if options.version?
          out.puts("rspec " + ::Rspec::Core::Version::STRING)
          # TODO this is copied in from RSpec 1.3
          # exit if stdout?
        elsif options.drb?
          # TODO check if it's possible to send a Configuration over Drb, and if so, unify the interface
          DRbProxy.new(:argv => options.to_drb_argv, :remote_port => options.drb_port || ENV['RSPEC_DRB'].to_i).run(err, out)
        else
          InProcess.new(configuration).run(err, out)
        end
      end

    private

      def configure(args)
        options = RSpec::Core::ConfigurationOptions.new(args)
        options.apply_to(configuration)
        configuration.require_files_to_run
        configuration.configure_mock_framework
        options
      end

      # TODO drb port
      class DRbProxy
        def initialize(options)
          @argv = options[:argv]
          @remote_port = options[:remote_port] # TODO default remote DRb port
        end

        def run(err, out)
          begin
            begin; \
              DRb.start_service("druby://localhost:0"); \
            rescue SocketError, Errno::EADDRNOTAVAIL; \
              DRb.start_service("druby://:0"); \
            end
            spec_server = DRbObject.new_with_uri("druby://127.0.0.1:#{@remote_port}")
            spec_server.run(@argv, err, out)
            true
          rescue DRb::DRbConnError
            err.puts "No server is running"
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
