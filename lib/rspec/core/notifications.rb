RSpec::Support.require_rspec_core "formatters/helpers"

module RSpec::Core
  # Notifications are value objects passed to formatters to provide them
  # with information about a particular event of interest.
  module Notifications

    # The `StartNotification` represents a notification sent by the reporter
    # when the suite is started. It contains the expected amount of examples
    # to be executed, and the load time of RSpec.
    #
    # @attr count [Fixnum] the number counted
    # @attr load_time [Float] the number of seconds taken to boot RSpec
    #                         and load the spec files
    StartNotification = Struct.new(:count, :load_time)

    # The `ExampleNotification` represents notifications sent by the reporter
    # which contain information about the current (or soon to be) example.
    # It is used by formatters to access information about that example.
    #
    # @example
    #   def example_started(notification)
    #     puts "Hey I started #{notification.example.description}"
    #   end
    #
    # @attr example [RSpec::Core::Example] the current example
    ExampleNotification = Struct.new(:example)

    # The `FailedExampleNotification` extends `ExampleNotification` with
    # things useful for failed specs.
    #
    # @example
    #   def example_failed(notification)
    #     puts "Hey I failed :("
    #     puts "Here's my stack trace"
    #     puts notification.exception.backtrace.join("\n")
    #   end
    #
    # @attr [RSpec::Core::Example] example the current example
    # @see ExampleNotification
    class FailedExampleNotification < ExampleNotification

      # @return [Exception] The example failure
      def exception
        example.execution_result.exception
      end

      # @return [String] The example description
      def description
        example.full_description
      end

      # Returns the message generated for this failure line by line.
      #
      # @return [Array(String)] The example failure message
      def message_lines
        @lines ||=
          begin
            lines = ["Failure/Error: #{read_failed_line.strip}"]
            lines << exception_class_name unless exception_class_name =~ /RSpec/
            exception.message.to_s.split("\n").each do |line|
              lines << line if exception.message
            end
            if shared_group
              lines << "Shared Example Group: \"#{shared_group.metadata[:shared_group_name]}\"" +
                " called from #{backtrace_formatter.backtrace_line(shared_group.location)}"
            end
            lines
          end
      end

      # Returns the message generated for this failure colorized line by line.
      #
      # @param colorizer [#wrap] An object to colorize the message_lines by
      # @return [Array(String)] The example failure message colorized
      def colorized_message_lines(colorizer)
        message_lines.map do |line|
          colorizer.wrap line, RSpec.configuration.failure_color
        end
      end

      # Returns the failures formatted backtrace.
      #
      # @return [Array(String)] the examples backtrace lines
      def formatted_backtrace
        backtrace_formatter.format_backtrace(exception.backtrace, example.metadata)
      end

      # Returns the failures colorized formatted backtrace.
      #
      # @param colorizer [#wrap] An object to colorize the message_lines by
      # @return [Array(String)] the examples colorized backtrace lines
      def colorized_formatted_backtrace(colorizer)
        formatted_backtrace.map do |backtrace_info|
          colorizer.wrap backtrace_info, RSpec.configuration.detail_color
        end
      end

    private

      def backtrace_formatter
        RSpec.configuration.backtrace_formatter
      end

      def exception_class_name
        name = exception.class.name.to_s
        name ="(anonymous error class)" if name == ''
        name
      end

      def shared_group
        @shared_group ||= group_and_parent_groups.find { |group| group.metadata[:shared_group_name] }
      end

      def group_and_parent_groups
        example.example_group.parent_groups + [example.example_group]
      end

      def read_failed_line
        unless matching_line = find_failed_line
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

      def find_failed_line
        path = File.expand_path(example.file_path)
        exception.backtrace.detect do |line|
          match = line.match(/(.+?):(\d+)(|:\d+)/)
          match && match[1].downcase == path.downcase
        end
      end
    end

    # The `PendingExampleFixedNotification` extends `ExampleNotification` with
    # things useful for specs that pass when they are expected to fail.
    #
    # @attr [RSpec::Core::Example] example the current example
    # @see ExampleNotification
    class PendingExampleFixedNotification < FailedExampleNotification

      # Returns the examples description
      #
      # @return [String] The example description
      def description
        "#{example.full_description} FIXED"
      end

      # Returns the message generated for this failure line by line.
      #
      # @return [Array(String)] The example failure message
      def message_lines
        ["Expected pending '#{example.execution_result.pending_message}' to fail. No Error was raised."]
      end

      # Returns the message generated for this failure colorized line by line.
      #
      # @param colorizer [#wrap] An object to colorize the message_lines by
      # @return [Array(String)] The example failure message colorized
      def colorized_message_lines(colorizer)
        message_lines.map { |line| colorizer.wrap(line, RSpec.configuration.fixed_color) }
      end
    end

    # The `GroupNotification` represents notifications sent by the reporter which
    # contain information about the currently running (or soon to be) example group
    # It is used by formatters to access information about that group.
    #
    # @example
    #   def example_group_started(notification)
    #     puts "Hey I started #{notification.group.description}"
    #   end
    # @attr group [RSpec::Core::ExampleGroup] the current group
    GroupNotification = Struct.new(:group)

    # The `MessageNotification` encapsulates generic messages that the reporter
    # sends to formatters.
    #
    # @attr message [String] the message
    MessageNotification = Struct.new(:message)

    # The `SeedNotification` holds the seed used to randomize examples and
    # wether that seed has been used or not.
    #
    # @attr seed [Fixnum] the seed used to randomize ordering
    # @attr used [Boolean] wether the seed has been used or not
    SeedNotification = Struct.new(:seed, :used) do
      # @api
      # @return [Boolean] has the seed been used?
      def seed_used?
        !!used
      end
      private :used
    end

    # The `SummaryNotification` holds information about the results of running
    # a test suite. It is used by formatters to provide information at the end
    # of the test run.
    #
    # @attr duration [Float] the time taken (in seconds) to run the suite
    # @attr example_count [Fixnum] the number of examples run
    # @attr failure_count [Fixnum] the number of failed examples
    # @attr pending_count [Fixnum] the number of pending examples
    # @attr load_time [Float] the number of seconds taken to boot RSpec
    #                         and load the spec files
    SummaryNotification = Struct.new(:duration, :example_count, :failure_count, :pending_count, :load_time) do
      # @api
      # @return [String] A line summarising the results of the spec run.
      def summary_line
        summary = Formatters::Helpers.pluralize(example_count, "example")
        summary << ", " << Formatters::Helpers.pluralize(failure_count, "failure")
        summary << ", #{pending_count} pending" if pending_count > 0
        summary
      end

      # @api public
      #
      # Wraps the summary line with colors based on the configured
      # colors for failure, pending, and success. Defaults to red,
      # yellow, green accordingly.
      #
      # @param colorizer [#wrap] An object which supports wrapping text with
      #                          specific colors.
      # @return [String] A colorized summary line.
      def colorize_with(colorizer)
        if failure_count > 0
          colorizer.wrap(summary_line, RSpec.configuration.failure_color)
        elsif pending_count > 0
          colorizer.wrap(summary_line, RSpec.configuration.pending_color)
        else
          colorizer.wrap(summary_line, RSpec.configuration.success_color)
        end
      end

      # @return [String] a formatted version of the time it took to run the suite
      def formatted_duration
        Formatters::Helpers.format_duration(duration)
      end

      # @return [String] a formatted version of the time it took to boot RSpec and
      #   load the spec files
      def formatted_load_time
        Formatters::Helpers.format_duration(load_time)
      end
    end

    # The `DeprecationNotification` is issued by the reporter when a deprecated
    # part of RSpec is encountered. It represents information about the deprecated
    # call site.
    #
    # @attr message [String] A custom message about the deprecation
    # @attr deprecated [String] A custom message about the deprecation (alias of message)
    # @attr replacement [String] An optional replacement for the deprecation
    # @attr call_site [String] An optional call site from which the deprecation was issued
    DeprecationNotification = Struct.new(:deprecated, :message, :replacement, :call_site) do
      private_class_method :new

      # @api
      # Convenience way to initialize the notification
      def self.from_hash(data)
        new data[:deprecated], data[:message], data[:replacement], data[:call_site]
      end
    end

    # `NullNotification` represents a placeholder value for notifications that
    # currently require no information, but we may wish to extend in future.
    class NullNotification
    end

  end
end
