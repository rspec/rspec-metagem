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
        Formatters.register self, :start, :example_group_started, :example_started,
                                  :example_pending, :example_failed, :close
        attr_accessor :example_group
        attr_reader :examples, :output
        attr_reader :failed_example_notifications, :pending_examples

        def failed_examples
          failed_example_notifications.map(&:example)
        end

        # @api public
        #
        # @param output [IO] the formatter output
        def initialize(output)
          @output = output || StringIO.new
          @example_count = @pending_count = @failure_count = 0
          @examples = []
          @failed_example_notifications = []
          @pending_examples = []
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

        # @api public
        #
        # Invoked at the beginning of the execution of each example.
        #
        # @param notification [ExampleNotification] containing example subclass of `RSpec::Core::Example`
        def example_started(notification)
          examples << notification.example
        end

        # @method example_passed
        # @api public
        #
        # Invoked when an example passes.
        #
        # @param notification [ExampleNotification] containing example subclass of `RSpec::Core::Example`

        # Invoked when an example is pending.
        #
        # @param notification [ExampleNotification] containing example subclass of `RSpec::Core::Example`
        def example_pending(notification)
          @pending_examples << notification.example
        end

        # @api public
        #
        # Invoked when an example fails.
        #
        # @param notification [ExampleNotification] containing example subclass of `RSpec::Core::Example`
        def example_failed(notification)
          @failed_example_notifications << notification
        end

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

      protected

        def configuration
          RSpec.configuration
        end

        def start_sync_output
          @old_sync, output.sync = output.sync, true if output_supports_sync
        end

        def restore_sync_output
          output.sync = @old_sync if output_supports_sync and !output.closed?
        end

        def output_supports_sync
          output.respond_to?(:sync=)
        end

        def profile_examples?
          configuration.profile_examples
        end

        def fail_fast?
          configuration.fail_fast
        end

        def color_enabled?
          configuration.color_enabled?(output)
        end

        def mute_profile_output?(failure_count)
          # Don't print out profiled info if there are failures and `--fail-fast` is used, it just clutters the output
          !profile_examples? || (fail_fast? && failure_count != 0)
        end

        # @api private
        def slowest_examples
          number_of_examples = RSpec.configuration.profile_examples
          sorted_examples = examples.sort_by {|example|
            example.execution_result.run_time }.reverse.first(number_of_examples)

          total, slows = [examples, sorted_examples].map do |exs|
            exs.inject(0.0) {|i, e| i + e.execution_result.run_time }
          end
          {:examples => sorted_examples, :total => total, :slows => slows}
        end

        # @api private
        def slowest_groups
          number_of_examples = RSpec.configuration.profile_examples
          example_groups = {}

          examples.each do |example|
            location = example.example_group.parent_groups.last.metadata[:location]

            example_groups[location] ||= Hash.new(0)
            example_groups[location][:total_time]  += example.execution_result.run_time
            example_groups[location][:count]       += 1
            example_groups[location][:description] = example.example_group.top_level_description unless example_groups[location].has_key?(:description)
          end

          # stop if we've only one example group
          return {} if example_groups.keys.length <= 1

          example_groups.each_value do |hash|
            hash[:average] = hash[:total_time].to_f / hash[:count]
          end

          example_groups.sort_by {|_, hash| -hash[:average]}.first(number_of_examples)
        end
      end
    end
  end
end
