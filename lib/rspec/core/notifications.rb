module RSpec::Core

  # The `CountNotification` represents notifications sent by the formatter
  # which a single numerical count attribute. Currently used to notify
  # formatters of the expected number of examples.
  #
  # @!attribute [r] count
  #   @return [Fixnum] the number counted
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
  # @!attribute [r] example
  #   @api
  #   @return [RSpec::Core::Example] the current example
  ExampleNotification = Struct.new(:example)

  # The `GroupNotification` represents notifications sent by the reporter which
  # contain information about the currently running (or soon to be) example group
  # It is used by formatters to access information about that group.
  #
  # @example
  #   def example_group_started(notification)
  #     puts "Hey I started #{notification.group.description}"
  #   end
  #
  # @!attribute [r] group
  #   @api
  #   @return [RSpec::Core::ExampleGroup] the current group
  GroupNotification = Struct.new(:group)

  # The `MessageNotification` encapsulates generic messages that the reporter
  # sends to formatters.
  #
  # @!attribute [r] message
  #   @return [String] the message
  MessageNotification = Struct.new(:message)

  # The `SeedNotification` holds the seed used to randomize examples and
  # wether that seed has been used or not.
  #
  # @!attribute [r] seed
  #   @return [Fixnum] the seed used to randomize ordering
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
  # @!attribute [r] duration
  #   @api
  #   @return [Float] the time taken (in seconds) to run the suite
  # @!attribute [r] examples
  #   @api
  #   @return [Fixnum] the number of examples run
  # @!attribute [r] failures
  #   @api
  #   @return [Fixnum] the number of failed examples
  # @!attribute [r] pending
  #   @api
  #   @return [Fixnum] the number of pending examples
  SummaryNotification = Struct.new(:duration, :examples, :failures, :pending)

  # The `DeprecationNotification` is issued by the reporter when a deprecated
  # part of RSpec is encountered. It represents information about the deprecated
  # call site.
  #
  # @!attribute [r] deprecated
  #   @api
  #   @return [String] The thing thats deprecated
  # @!attribute [r] message
  #   @api
  #   @return [String] A custom message about the deprecation
  # @!attribute [r] replacement
  #   @api
  #   @return [String] An optional replacement for the deprecation
  # @!attribute [r] call_site
  #   @api
  #   @return [String] An optional call site from which the deprecation was issued
  DeprecationNotification = Struct.new(:message, :replacement, :deprecated, :call_site) do
    # @api
    # Convenience way to initialize the notification
    def self.from_hash(data)
      new data[:message], data[:replacement], data[:deprecated], data[:call_site]
    end
  end

  # `Notification` represents a placeholder value for notifications that
  # currently require no information, but we may wish to extend in future.
  class Notification
  end

end
