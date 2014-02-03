require 'rspec/core/formatters/helpers'
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
        include Helpers
        attr_accessor :example_group
        attr_reader :examples, :output
        attr_reader :failed_examples, :pending_examples

        # @api public
        #
        # @param output
        def initialize(output)
          @output = output || StringIO.new
          @example_count = @pending_count = @failure_count = 0
          @examples = []
          @failed_examples = []
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
        # @param example_count
        def start(notification)
          start_sync_output
          @example_count = notification.count
        end

        # @api public
        #
        # This method is invoked at the beginning of the execution of each example group.
        #
        # @param example_group subclass of `RSpec::Core::ExampleGroup`
        #
        # The next method to be invoked after this is {#example_passed},
        # {#example_pending}, or {#example_group_finished}.
        #
        # @param example_group
        def example_group_started(notification)
          @example_group = notification.group
        end

        # @method example_group_finished
        # @api public
        #
        # Invoked at the end of the execution of each example group.
        #
        # @param example_group subclass of `RSpec::Core::ExampleGroup`

        # @api public
        #
        # Invoked at the beginning of the execution of each example.
        #
        # @param example instance of subclass of `RSpec::Core::ExampleGroup`
        # @return [Array]
        def example_started(notification)
          examples << notification.example
        end

        # @method example_passed
        # @api public
        #
        # Invoked when an example passes.
        #
        # @param example instance of subclass of `RSpec::Core::ExampleGroup`

        # Invoked when an example is pending.
        #
        # @param example instance of subclass of `RSpec::Core::ExampleGroup`
        # @return [Array]
        def example_pending(notification)
          @pending_examples << notification.example
        end

        # @api public
        #
        # Invoked when an example fails.
        #
        # @param example instance of subclass of `RSpec::Core::ExampleGroup`
        # @return [Array]
        def example_failed(notification)
          @failed_examples << notification.example
        end

        # @method message
        # @api public
        #
        # Used by the reporter to send messages to the output stream.
        #
        # @param [String] message

        # @method stop
        # @api public
        #
        # Invoked after all examples have executed, before dumping post-run reports.
        #
        # @return [nil]

        # @method start_dump
        # @api public
        #
        # This method is invoked after all of the examples have executed. The next method
        # to be invoked after this one is {#dump_failures}
        # (BaseTextFormatter then calls {#dump_failure} once for each failed example.)
        #
        # @return [nil]

        # @method dump_failures
        # @api public
        #
        # Dumps detailed information about each example failure.
        #
        # @return [nil]

        # @method dump_summary
        # @api public
        #
        # This method is invoked after the dumping of examples and failures. Each parameter
        # is assigned to a corresponding attribute.
        #
        # @param duration
        # @param example_count
        # @param failure_count
        # @param pending_count

        # @method dump_pending
        # @api public
        #
        # Outputs a report of pending examples.  This gets invoked
        # after the summary if option is set to do so.
        #
        # @return [nil]

        # @method dump_profile
        # @api public
        #
        # This methods is invoked form formatters to show slowest examples and example groups
        # when using `--profile COUNT` (default 10).
        #
        # @return [nil]

        # @api public
        #
        # Invoked at the very end, `close` allows the formatter to clean
        # up resources, e.g. open streams, etc.
        def close(notification)
          restore_sync_output
        end

        # @api public
        #
        # Formats the given backtrace based on configuration and
        # the metadata of the given example.
        def format_backtrace(backtrace, example)
          configuration.backtrace_formatter.format_backtrace(backtrace, example.metadata)
        end

      protected

        def configuration
          RSpec.configuration
        end

        def read_failed_line(exception, example)
          unless matching_line = find_failed_line(exception.backtrace, example.file_path)
            return "Unable to find matching line from backtrace"
          end

          file_path, line_number = matching_line.match(/(.+?):(\d+)(|:\d+)/)[1..2]

          if File.exist?(file_path)
            File.readlines(file_path)[line_number.to_i - 1] ||
              "Unable to find matching line in #{file_path}"
          else
            "Unable to find #{file_path} to read failed line"
          end
        rescue SecurityError
          "Unable to read failed line"
        end

        def find_failed_line(backtrace, path)
          path = File.expand_path(path)
          backtrace.detect { |line|
            match = line.match(/(.+?):(\d+)(|:\d+)/)
            match && match[1].downcase == path.downcase
          }
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
            example.execution_result[:run_time] }.reverse.first(number_of_examples)

          total, slows = [examples, sorted_examples].map do |exs|
            exs.inject(0.0) {|i, e| i + e.execution_result[:run_time] }
          end
          {:examples => sorted_examples, :total => total, :slows => slows}
        end

        # @api private
        def slowest_groups
          number_of_examples = RSpec.configuration.profile_examples
          example_groups = {}

          examples.each do |example|
            location = example.example_group.parent_groups.last.metadata[:example_group][:location]

            example_groups[location] ||= Hash.new(0)
            example_groups[location][:total_time]  += example.execution_result[:run_time]
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
