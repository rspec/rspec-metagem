require 'drb/drb'

module RSpec
  module Core
    module Formatters
      # Used by `--bisect`. When it shells out and runs a portion of the suite, it uses
      # this formatter as a means to have the status reported back to it, via DRb.
      #
      # Note that since DRb calls carry considerable overhead compared to normal
      # method calls, we try to minimize the number of DRb calls for perf reasons,
      # opting to communicate only at the start and the end of the run, rather than
      # after each example.
      # @private
      class BisectFormatter
        Formatters.register self, :start_dump, :example_failed, :example_finished

        def initialize(_output)
          drb_uri = "druby://localhost:#{RSpec.configuration.drb_port}"
          @bisect_server = DRbObject.new_with_uri(drb_uri)
          RSpec.configuration.files_or_directories_to_run = @bisect_server.files_or_directories_to_run

          @all_example_ids = []
          @failed_example_ids = []
          @remaining_failures = Set.new(@bisect_server.expected_failures)
        end

        def example_failed(notification)
          @failed_example_ids << notification.example.id
        end

        def example_finished(notification)
          @all_example_ids << notification.example.id
          return unless @remaining_failures.include?(notification.example.id)
          @remaining_failures.delete(notification.example.id)

          status = notification.example.execution_result.status
          return if status == :failed && !@remaining_failures.empty?
          RSpec.world.wants_to_quit = true
        end

        def start_dump(_notification)
          @bisect_server.latest_run_results = RunResults.new(
            @all_example_ids, @failed_example_ids
          )
        end

        RunResults = Struct.new(:all_example_ids, :failed_example_ids)
      end
    end
  end
end
