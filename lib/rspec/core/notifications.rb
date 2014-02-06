require 'rspec/core/formatters/helpers'

module RSpec::Core
  module Notifications

    # The `CountNotification` represents notifications sent by the formatter
    # which a single numerical count attribute. Currently used to notify
    # formatters of the expected number of examples.
    #
    # @attr [Fixnum] count the number counted
    CountNotification = Struct.new(:count)

    # The `ExampleNotification` represents notifications sent by the reporter
    # which contain information about the current (or soon to be) example.
    # It is used by formatters to access information about that example.
    #
    # @example
    #   def example_started(notification)
    #     puts "Hey I started #{notification.example.description}"
    #   end
    #
    # @attr [RSpec::Core::Example] example the current example
    ExampleNotification = Struct.new(:example)

    # The `GroupNotification` represents notifications sent by the reporter which
    # contain information about the currently running (or soon to be) example group
    # It is used by formatters to access information about that group.
    #
    # @example
    #   def example_group_started(notification)
    #     puts "Hey I started #{notification.group.description}"
    #   end
    # @attr [RSpec::Core::ExampleGroup] group the current group
    GroupNotification = Struct.new(:group)

    # The `MessageNotification` encapsulates generic messages that the reporter
    # sends to formatters.
    #
    # @attr [String] message the message
    MessageNotification = Struct.new(:message)

    # The `SeedNotification` holds the seed used to randomize examples and
    # wether that seed has been used or not.
    #
    # @attr [Fixnum] seed the seed used to randomize ordering
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
    # @attr [Float] duration the time taken (in seconds) to run the suite
    # @attr [Fixnum] example_count the number of examples run
    # @attr [Fixnum] failure_count the number of failed examples
    # @attr [Fixnum] pending_count the number of pending examples
    class SummaryNotification < Struct.new(:duration, :example_count, :failure_count, :pending_count)
      include Formatters::Helpers

      # @api
      # @return [String] A line summarising the results of the spec run.
      def summary_line
        summary = pluralize(example_count, "example")
        summary << ", " << pluralize(failure_count, "failure")
        summary << ", #{pending_count} pending" if pending_count > 0
        summary
      end
    end

    # The `DeprecationNotification` is issued by the reporter when a deprecated
    # part of RSpec is encountered. It represents information about the deprecated
    # call site.
    #
    # @attr [String] message A custom message about the deprecation
    # @attr [String] deprecated A custom message about the deprecation (alias of message)
    # @attr [String] replacement An optional replacement for the deprecation
    # @attr [String] call_site An optional call site from which the deprecation was issued
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
