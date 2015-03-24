RSpec::Support.require_rspec_core "bisect/server"
RSpec::Support.require_rspec_core "bisect/runner"
RSpec::Support.require_rspec_core "bisect/example_minimizer"
RSpec::Support.require_rspec_core "formatters/bisect_progress_formatter"

module RSpec
  module Core
    module Bisect
      # @private
      # The main entry point into the bisect logic. Coordinates among:
      #   - Bisect::Server: Receives suite results.
      #   - Bisect::Runner: Runs a set of examples and directs the results
      #     to the server.
      #   - Bisect::ExampleMinimizer: Contains the core bisect logic.
      #   - Formatters::BisectProgressFormatter: provides progress updates
      #     to the user.
      class Coordinator
        def self.bisect_with(original_cli_args, configuration)
          new(original_cli_args, configuration).bisect
        end

        def initialize(original_cli_args, configuration)
          @original_cli_args = original_cli_args
          @configuration     = configuration
        end

        def bisect
          @configuration.add_formatter Formatters::BisectProgressFormatter

          reporter.close_after do
            repro = Server.run do |server|
              runner    = Runner.new(server, @original_cli_args)
              minimizer = ExampleMinimizer.new(runner, reporter)
              runner.repro_command_from(minimizer.find_minimal_repro)
            end

            reporter.publish(:bisect_repro_command, :repro => repro)
          end
        end

      private

        def reporter
          @configuration.reporter
        end
      end
    end
  end
end
