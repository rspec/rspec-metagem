module RSpec::Core
  # A reporter will send notifications to listeners, usually formatters for the
  # spec suite run.
  class Reporter
    def initialize(configuration)
      @configuration = configuration
      @listeners = Hash.new { |h, k| h[k] = Set.new }
      @examples = []
      @failed_examples = []
      @pending_examples = []
      @duration = @start = @load_time = nil
    end

    # @private
    attr_reader :examples, :failed_examples, :pending_examples

    # Registers a listener to a list of notifications. The reporter will send notification of
    # events to all registered listeners
    #
    # @param listener [Object] An obect that wishes to be notified of reporter events
    # @param notifications [Array] Array of symbols represents the events a listener wishes to subscribe too
    def register_listener(listener, *notifications)
      notifications.each do |notification|
        @listeners[notification.to_sym] << listener
      end
      true
    end

    # @private
    def registered_listeners(notification)
      @listeners[notification].to_a
    end

    # @api
    # @overload report(count, &block)
    # @overload report(count, &block)
    # @param expected_example_count [Integer] the number of examples being run
    # @yield [Block] block yields itself for further reporting.
    #
    # Initializes the report run and yields itself for further reporting. The
    # block is required, so that the reporter can manage cleaning up after the
    # run.
    #
    # @example
    #
    #     reporter.report(group.examples.size) do |r|
    #       example_groups.map {|g| g.run(r) }
    #     end
    #
    def report(expected_example_count)
      start(expected_example_count)
      begin
        yield self
      ensure
        finish
      end
    end

    # @private
    def start(expected_example_count, time=RSpec::Core::Time.now)
      @start = time
      @load_time = (@start - @configuration.start_time).to_f
      notify :start, Notifications::StartNotification.new(expected_example_count, @load_time)
    end

    # @private
    def message(message)
      notify :message, Notifications::MessageNotification.new(message)
    end

    # @private
    def example_group_started(group)
      notify :example_group_started, Notifications::GroupNotification.new(group) unless group.descendant_filtered_examples.empty?
    end

    # @private
    def example_group_finished(group)
      notify :example_group_finished, Notifications::GroupNotification.new(group) unless group.descendant_filtered_examples.empty?
    end

    # @private
    def example_started(example)
      @examples << example
      notify :example_started, Notifications::ExampleNotification.for(example)
    end

    # @private
    def example_passed(example)
      notify :example_passed, Notifications::ExampleNotification.for(example)
    end

    # @private
    def example_failed(example)
      @failed_examples << example
      notify :example_failed, Notifications::ExampleNotification.for(example)
    end

    # @private
    def example_pending(example)
      @pending_examples << example
      notify :example_pending, Notifications::ExampleNotification.for(example)
    end

    # @private
    def deprecation(hash)
      notify :deprecation, Notifications::DeprecationNotification.from_hash(hash)
    end

    # @private
    def finish
      stop
      notify :start_dump,    Notifications::NullNotification
      notify :dump_pending,  Notifications::ExamplesNotification.new(self)
      notify :dump_failures, Notifications::ExamplesNotification.new(self)
      notify :deprecation_summary, Notifications::NullNotification
      notify :dump_summary, Notifications::SummaryNotification.new(@duration, @examples, @failed_examples, @pending_examples, @load_time)
      unless mute_profile_output?
        notify :dump_profile, Notifications::ProfileNotification.new(@duration, @examples, @configuration.profile_examples)
      end
      notify :seed, Notifications::SeedNotification.new(@configuration.seed, seed_used?)
    ensure
      notify :close, Notifications::NullNotification
    end

    # @private
    def stop
      @duration = (RSpec::Core::Time.now - @start).to_f if @start
      notify :stop, Notifications::ExamplesNotification.new(self)
    end

    # @private
    def notify(event, notification)
      registered_listeners(event).each do |formatter|
        formatter.__send__(event, notification)
      end
    end

  private

    def mute_profile_output?
      # Don't print out profiled info if there are failures and `--fail-fast` is used, it just clutters the output
      !@configuration.profile_examples? || (@configuration.fail_fast? && @failed_examples.size > 0)
    end

    def seed_used?
      @configuration.seed && @configuration.seed_used?
    end
  end
end
