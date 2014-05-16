RSpec::Support.require_rspec_core "formatters/base_formatter"
RSpec::Support.require_rspec_core "formatters/console_codes"

module RSpec
  module Core
    module Formatters

      # Base for all of RSpec's built-in formatters. See RSpec::Core::Formatters::BaseFormatter
      # to learn more about all of the methods called by the reporter.
      #
      # @see RSpec::Core::Formatters::BaseFormatter
      # @see RSpec::Core::Reporter
      class BaseTextFormatter < BaseFormatter
        Formatters.register self, :message, :dump_summary, :dump_failures,
                                  :dump_pending, :seed

        # @method message
        # @api public
        #
        # Used by the reporter to send messages to the output stream.
        #
        # @param notification [MessageNotification] containing message
        def message(notification)
          output.puts notification.message
        end

        # @method dump_failures
        # @api public
        #
        # Dumps detailed information about each example failure.
        #
        # @param notification [NullNotification]
        def dump_failures(notification)
          return if notification.failure_notifications.empty?
          output.puts
          output.puts "Failures:"
          notification.failure_notifications.each_with_index do |failure, index|
            output.puts
            output.puts "#{short_padding}#{index.next}) #{failure.description}"
            failure.colorized_message_lines.each do |line|
              output.puts "#{long_padding}#{line}"
            end
            failure.colorized_formatted_backtrace.each do |line|
              output.puts "#{long_padding}#{line}"
            end
          end
        end

        # @method dump_summary
        # @api public
        #
        # This method is invoked after the dumping of examples and failures. Each parameter
        # is assigned to a corresponding attribute.
        #
        # @param summary [SummaryNotification] containing duration, example_count,
        #                                      failure_count and pending_count
        def dump_summary(summary)
          output.puts "\nFinished in #{summary.formatted_duration}" +
                      " (files took #{summary.formatted_load_time} to load)\n"
          output.puts summary.colorized_results_line
          unless summary.failed_examples.empty?
            output.puts summary.colorized_rerun_commands
          end
        end

        # @private
        def dump_pending(notification)
          unless notification.pending_examples.empty?
            output.puts
            output.puts "Pending:"
            notification.pending_examples.each do |pending_example|
              output.puts color("  #{pending_example.full_description}", :pending)
              output.puts color("    # #{pending_example.execution_result.pending_message}", :detail)
              output.puts color("    # #{format_caller(pending_example.location)}", :detail)
            end
          end
        end

        # @private
        def seed(notification)
          return unless notification.seed_used?
          output.puts
          output.puts "Randomized with seed #{notification.seed}"
          output.puts
        end

        # @api public
        #
        # Invoked at the very end, `close` allows the formatter to clean
        # up resources, e.g. open streams, etc.
        #
        # @param notification [NullNotification]
        def close(notification)
          output.close if IO === output && output != $stdout
        end

      protected

        def short_padding
          '  '
        end

        def long_padding
          '     '
        end

      private

        def color(text, color_code)
          ConsoleCodes.wrap(text, color_code)
        end

        def format_caller(caller_info)
          RSpec.configuration.backtrace_formatter.backtrace_line(caller_info.to_s.split(':in `block').first)
        end

      end
    end
  end
end
