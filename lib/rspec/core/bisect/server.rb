require 'drb/drb'

module RSpec
  module Core
    # @private
    module Bisect
      # @private
      # A DRb server that receives run results from a separate RSpec process
      # started by the bisect process.
      class Server
        def self.run
          server = new
          server.start
          yield server
        ensure
          server.stop
        end

        def capture_run_results(abort_after_example_id=nil)
          self.abort_after_example_id = abort_after_example_id
          yield
          latest_run_results
        end

        def start
          # We pass `nil` as the first arg to allow it to pick a DRb port.
          @drb = DRb.start_service(nil, self)
        end

        def stop
          @drb.stop_service
        end

        def drb_port
          @drb_port ||= Integer(@drb.uri[/\d+$/])
        end

        # Fetched via DRb by the BisectFormatter to determine when to abort.
        attr_accessor :abort_after_example_id

        # Set via DRb by the BisectFormatter with the results of the run.
        attr_accessor :latest_run_results
      end
    end
  end
end
