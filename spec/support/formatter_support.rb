module FormatterSupport

  def send_notification type, notification
    reporter.notify type, notification
  end

  def reporter
    @reporter ||= setup_reporter
  end

  def setup_reporter(*streams)
    config.add_formatter described_class, *streams
    @formatter = config.formatters.first
    @reporter = config.reporter
  end

  def output
    @output ||= StringIO.new
  end

  def config
    @configuration ||=
      begin
        config = RSpec::Core::Configuration.new
        config.output_stream = output
        config
      end
  end

  def configure
    yield config
  end

  def formatter
    @formatter ||=
      begin
        setup_reporter
        @formatter
      end
  end

  def example
    result = { :exception => Exception.new }
    allow(result).to receive(:pending_fixed?) { false }
    allow(result).to receive(:status) { :passed }
    instance_double(RSpec::Core::Example,
                    :description       => "Example",
                    :full_description  => "Example",
                    :execution_result  => result,
                    :location          => "",
                    :metadata          => {}
                   )
  end

  def examples(n)
    (1..n).map { example }
  end

  def group
    class_double "RSpec::Core::ExampleGroup", :description => "Group"
  end

  def start_notification(count)
   ::RSpec::Core::Notifications::StartNotification.new count
  end

  def stop_notification
   ::RSpec::Core::Notifications::ExamplesNotification.new reporter.examples
  end

  def example_notification(specific_example = example)
   ::RSpec::Core::Notifications::ExampleNotification.for specific_example
  end

  def group_notification
   ::RSpec::Core::Notifications::GroupNotification.new group
  end

  def message_notification(message)
    ::RSpec::Core::Notifications::MessageNotification.new message
  end

  def null_notification
    ::RSpec::Core::Notifications::NullNotification
  end

  def seed_notification(seed, used = true)
    ::RSpec::Core::Notifications::SeedNotification.new seed, used
  end

  def failed_examples_notification
    ::RSpec::Core::Notifications::FailedExamplesNotification.new reporter.failed_examples
  end

  def summary_notification(duration, examples, failed, pending, time)
    ::RSpec::Core::Notifications::SummaryNotification.new duration, examples, failed, pending, time
  end

  def profile_notification(duration, examples, number)
    ::RSpec::Core::Notifications::ProfileNotification.new duration, examples, number
  end

end
