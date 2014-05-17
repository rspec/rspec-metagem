RSpec::Support.require_rspec_core "formatters/helpers"
require 'stringio'

module RSpec
  module Core
    module Formatters
      # RSpec's built-in formatters are all subclasses of RSpec::Core::Formatters::BaseTextFormatter,
      # but the BaseTextFormatter documents all of the notifications implemented as part of the standard
      # interface. The reporter will issue these during a normal test suite run, but a formatter will
      # only receive those notifications it has registered itself to receive.
      #
      # @see RSpec::Core::Formatters::BaseTextFormatter
      # @see RSpec::Core::Reporter
      class BaseFormatter

        # all formatters inheriting from this formatter will receive these notifications
        Formatters.register self, :start, :example_group_started, :close
        attr_accessor :example_group
        attr_reader :output

        # @api public
        #
        # @param output [IO] the formatter output
        def initialize(output)
          @output = output || StringIO.new
          @example_group = nil
        end

        # @api public
        #
        # This method is invoked before any examples are run, right after
        # they have all been collected. This can be useful for special
        # formatters that need to provide progress on feedback (graphical ones).
        #
        # This will only be invoked once, and the next one to be invoked
        # is {#example_group_started}.
        #
        # @param notification [StartNotification]
        def start(notification)
          start_sync_output
          @example_count = notification.count
        end

        # @api public
        #
        # This method is invoked at the beginning of the execution of each example group.
        #
        # The next method to be invoked after this is {#example_passed},
        # {#example_pending}, or {#example_group_finished}.
        #
        # @param notification [GroupNotification] containing example_group subclass of `RSpec::Core::ExampleGroup`
        def example_group_started(notification)
          @example_group = notification.group
        end

        # @method example_group_finished
        # @api public
        #
        # Invoked at the end of the execution of each example group.
        #
        # @param notification [GroupNotification] containing example_group subclass of `RSpec::Core::ExampleGroup`

        # @method example_started
        # @api public
        #
        # Invoked at the beginning of the execution of each example.
        #
        # @param notification [ExampleNotification] containing example subclass of `RSpec::Core::Example`

        # @method example_passed
        # @api public
        #
        # Invoked when an example passes.
        #
        # @param notification [ExampleNotification] containing example subclass of `RSpec::Core::Example`

        # @method example_pending
        # Invoked when an example is pending.
        #
        # @param notification [ExampleNotification] containing example subclass of `RSpec::Core::Example`

        # @method example_failed
        # @api public
        #
        # Invoked when an example fails.
        #
        # @param notification [ExampleNotification] containing example subclass of `RSpec::Core::Example`

        # @method message
        # @api public
        #
        # Used by the reporter to send messages to the output stream.
        #
        # @param notification [MessageNotification] containing message

        # @method stop
        # @api public
        #
        # Invoked after all examples have executed, before dumping post-run reports.
        #
        # @param notification [NullNotification]

        # @method start_dump
        # @api public
        #
        # This method is invoked after all of the examples have executed. The next method
        # to be invoked after this one is {#dump_failures}
        # (BaseTextFormatter then calls {#dump_failure} once for each failed example.)
        #
        # @param notification [NullNotification]

        # @method dump_failures
        # @api public
        #
        # Dumps detailed information about each example failure.
        #
        # @param notification [NullNotification]

        # @method dump_summary
        # @api public
        #
        # This method is invoked after the dumping of examples and failures. Each parameter
        # is assigned to a corresponding attribute.
        #
        # @param summary [SummaryNotification] containing duration, example_count,
        #                                      failure_count and pending_count

        # @method dump_profile
        # @api public
        #
        # This method is invoked after the dumping the summary if profiling is
        # enabled.
        #
        # @param profile [ProfileNotification] containing duration, slowest_examples
        #                                      and slowest_example_groups

        # @method dump_pending
        # @api public
        #
        # Outputs a report of pending examples.  This gets invoked
        # after the summary if option is set to do so.
        #
        # @param notification [NullNotification]

        # @api public
        #
        # Invoked at the very end, `close` allows the formatter to clean
        # up resources, e.g. open streams, etc.
        #
        # @param notification [NullNotification]
        def close(notification)
          restore_sync_output
        end

      private

        def start_sync_output
          @old_sync, output.sync = output.sync, true if output_supports_sync
        end

        def restore_sync_output
          output.sync = @old_sync if output_supports_sync and !output.closed?
        end

        def output_supports_sync
          output.respond_to?(:sync=)
        end

      end
    end
  end
end
