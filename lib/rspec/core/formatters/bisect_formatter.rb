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
        Formatters.register self, :start, :start_dump, :example_started,
                            :example_failed, :example_passed, :example_pending

        def initialize(_output)
          port                = RSpec.configuration.drb_port
          drb_uri             = "druby://127.0.0.1:#{port}"
          @all_example_ids    = []
          @failed_example_ids = []
          @bisect_server      = DRbObject.new_with_uri(drb_uri)
          @abort_after_id     = nil
        end

        def start(_notification)
          @abort_after_id = @bisect_server.abort_after_example_id
        end

        def example_started(notification)
          @all_example_ids << notification.example.id
        end

        def example_failed(notification)
          @failed_example_ids << notification.example.id
          example_finished(notification)
        end

        def example_passed(notification)
          example_finished(notification)
        end

        def example_pending(notification)
          example_finished(notification)
        end

        def start_dump(_notification)
          @bisect_server.latest_run_results = RunResults.new(
            @all_example_ids, @failed_example_ids
          )
        end

        RunResults = Struct.new(:all_example_ids, :failed_example_ids)

      private

        def example_finished(notification)
          return unless notification.example.id == @abort_after_id
          RSpec.world.wants_to_quit = true
        end
      end
    end
  end
end
