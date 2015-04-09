module FormatterSupport
  def run_example_specs_with_formatter(formatter_option, normalize_output=true)
    options = RSpec::Core::ConfigurationOptions.new(%W[spec/rspec/core/resources/formatter_specs.rb --format #{formatter_option} --order defined])

    err, out = StringIO.new, StringIO.new
    err.set_encoding("utf-8") if err.respond_to?(:set_encoding)

    runner = RSpec::Core::Runner.new(options)
    configuration = runner.instance_variable_get("@configuration")
    configuration.backtrace_formatter.exclusion_patterns << /rspec_with_simplecov/
    configuration.backtrace_formatter.inclusion_patterns = []

    runner.run(err, out)

    output = out.string
    return output unless normalize_output
    output = normalize_durations(output)

    caller_line = RSpec::Core::Metadata.relative_path(caller.first)
    output.lines.reject do |line|
      # remove the direct caller as that line is different for the summary output backtraces
      line.include?(caller_line) ||

      # ignore scirpt/rspec_with_simplecov because we don't usually have it locally but
      # do have it on travis
      line.include?("script/rspec_with_simplecov") ||

      # this line varies a bit depending on how you run the specs (via `rake` vs `rspec`)
      line.include?('/exe/rspec:')
    end.join
  end

  def normalize_durations(output)
    output.gsub(/(?:\d+ minutes? )?\d+(?:\.\d+)?(s| seconds?)/) do |dur|
      suffix = $1 == "s" ? "s" : " seconds"
      "n.nnnn#{suffix}"
    end
  end

  if RUBY_VERSION.to_f < 1.9
    def expected_summary_output_for_example_specs
      <<-EOS.gsub(/^\s+\|/, '').chomp
        |Pending: (Failures listed here are expected and do not affect your suite's status)
        |
        |  1) pending spec with no implementation is pending
        |     # Not yet implemented
        |     # ./spec/rspec/core/resources/formatter_specs.rb:4
        |
        |  2) pending command with block format with content that would fail is pending
        |     # No reason given
        |     Failure/Error: expect(1).to eq(2)
        |
        |       expected: 2
        |            got: 1
        |
        |       (compared using ==)
        |     # ./spec/rspec/core/resources/formatter_specs.rb:11
        |     # ./spec/support/formatter_support.rb:13:in `run_example_specs_with_formatter'
        |     # ./spec/support/sandboxing.rb:14
        |     # ./spec/support/sandboxing.rb:7
        |
        |Failures:
        |
        |  1) pending command with block format with content that would pass fails FIXED
        |     Expected pending 'No reason given' to fail. No Error was raised.
        |     # ./spec/rspec/core/resources/formatter_specs.rb:16
        |
        |  2) failing spec fails
        |     Failure/Error: expect(1).to eq(2)
        |
        |       expected: 2
        |            got: 1
        |
        |       (compared using ==)
        |     # ./spec/rspec/core/resources/formatter_specs.rb:31
        |     # ./spec/support/formatter_support.rb:13:in `run_example_specs_with_formatter'
        |     # ./spec/support/sandboxing.rb:14
        |     # ./spec/support/sandboxing.rb:7
        |
        |  3) a failing spec with odd backtraces fails with a backtrace that has no file
        |     Failure/Error: Unable to find matching line from backtrace
        |     RuntimeError:
        |       foo
        |     # (erb):1
        |
        |  4) a failing spec with odd backtraces fails with a backtrace containing an erb file
        |     Failure/Error: Unable to find matching line from backtrace
        |     Exception:
        |       Exception
        |     # /foo.html.erb:1:in `<main>': foo (RuntimeError)
        |
        |Finished in n.nnnn seconds (files took n.nnnn seconds to load)
        |7 examples, 4 failures, 2 pending
        |
        |Failed examples:
        |
        |rspec ./spec/rspec/core/resources/formatter_specs.rb:16 # pending command with block format with content that would pass fails
        |rspec ./spec/rspec/core/resources/formatter_specs.rb:30 # failing spec fails
        |rspec ./spec/rspec/core/resources/formatter_specs.rb:36 # a failing spec with odd backtraces fails with a backtrace that has no file
        |rspec ./spec/rspec/core/resources/formatter_specs.rb:42 # a failing spec with odd backtraces fails with a backtrace containing an erb file
      EOS
    end
  else
    def expected_summary_output_for_example_specs
      <<-EOS.gsub(/^\s+\|/, '').chomp
        |Pending: (Failures listed here are expected and do not affect your suite's status)
        |
        |  1) pending spec with no implementation is pending
        |     # Not yet implemented
        |     # ./spec/rspec/core/resources/formatter_specs.rb:4
        |
        |  2) pending command with block format with content that would fail is pending
        |     # No reason given
        |     Failure/Error: expect(1).to eq(2)
        |
        |       expected: 2
        |            got: 1
        |
        |       (compared using ==)
        |     # ./spec/rspec/core/resources/formatter_specs.rb:11:in `block (3 levels) in <top (required)>'
        |     # ./spec/support/formatter_support.rb:13:in `run_example_specs_with_formatter'
        |     # ./spec/support/sandboxing.rb:14:in `block (3 levels) in <top (required)>'
        |     # ./spec/support/sandboxing.rb:7:in `block (2 levels) in <top (required)>'
        |
        |Failures:
        |
        |  1) pending command with block format with content that would pass fails FIXED
        |     Expected pending 'No reason given' to fail. No Error was raised.
        |     # ./spec/rspec/core/resources/formatter_specs.rb:16
        |
        |  2) failing spec fails
        |     Failure/Error: expect(1).to eq(2)
        |
        |       expected: 2
        |            got: 1
        |
        |       (compared using ==)
        |     # ./spec/rspec/core/resources/formatter_specs.rb:31:in `block (2 levels) in <top (required)>'
        |     # ./spec/support/formatter_support.rb:13:in `run_example_specs_with_formatter'
        |     # ./spec/support/sandboxing.rb:14:in `block (3 levels) in <top (required)>'
        |     # ./spec/support/sandboxing.rb:7:in `block (2 levels) in <top (required)>'
        |
        |  3) a failing spec with odd backtraces fails with a backtrace that has no file
        |     Failure/Error: ERB.new("<%= raise 'foo' %>").result
        |     RuntimeError:
        |       foo
        |     # (erb):1:in `<main>'
        |     # ./spec/rspec/core/resources/formatter_specs.rb:39:in `block (2 levels) in <top (required)>'
        |     # ./spec/support/formatter_support.rb:13:in `run_example_specs_with_formatter'
        |     # ./spec/support/sandboxing.rb:14:in `block (3 levels) in <top (required)>'
        |     # ./spec/support/sandboxing.rb:7:in `block (2 levels) in <top (required)>'
        |
        |  4) a failing spec with odd backtraces fails with a backtrace containing an erb file
        |     Failure/Error: Unable to find matching line from backtrace
        |     Exception:
        |       Exception
        |     # /foo.html.erb:1:in `<main>': foo (RuntimeError)
        |
        |Finished in n.nnnn seconds (files took n.nnnn seconds to load)
        |7 examples, 4 failures, 2 pending
        |
        |Failed examples:
        |
        |rspec ./spec/rspec/core/resources/formatter_specs.rb:16 # pending command with block format with content that would pass fails
        |rspec ./spec/rspec/core/resources/formatter_specs.rb:30 # failing spec fails
        |rspec ./spec/rspec/core/resources/formatter_specs.rb:36 # a failing spec with odd backtraces fails with a backtrace that has no file
        |rspec ./spec/rspec/core/resources/formatter_specs.rb:42 # a failing spec with odd backtraces fails with a backtrace containing an erb file
      EOS
    end
  end

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

  def formatter_output
    @formatter_output ||= StringIO.new
  end

  def config
    @configuration ||=
      begin
        config = RSpec::Core::Configuration.new
        config.output_stream = formatter_output
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

  def new_example(metadata = {})
    metadata = metadata.dup
    result = RSpec::Core::Example::ExecutionResult.new
    result.started_at = ::Time.now
    result.record_finished(metadata.delete(:status) { :passed }, ::Time.now)
    result.exception = Exception.new if result.status == :failed

    instance_double(RSpec::Core::Example,
                     :description             => "Example",
                     :full_description        => "Example",
                     :execution_result        => result,
                     :location                => "",
                     :location_rerun_argument => "",
                     :metadata                => {
                       :shared_group_inclusion_backtrace => []
                     }.merge(metadata)
                   )
  end

  def examples(n)
    Array.new(n) { new_example }
  end

  def group
    class_double "RSpec::Core::ExampleGroup", :description => "Group"
  end

  def start_notification(count)
   ::RSpec::Core::Notifications::StartNotification.new count
  end

  def stop_notification
   ::RSpec::Core::Notifications::ExamplesNotification.new reporter
  end

  def example_notification(specific_example = new_example)
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
    ::RSpec::Core::Notifications::ExamplesNotification.new reporter
  end

  def summary_notification(duration, examples, failed, pending, time)
    ::RSpec::Core::Notifications::SummaryNotification.new duration, examples, failed, pending, time
  end

  def profile_notification(duration, examples, number)
    ::RSpec::Core::Notifications::ProfileNotification.new duration, examples, number
  end

end

if RSpec::Support::RubyFeatures.module_prepends_supported?
  module RSpec::Core
    class Reporter
      module EnforceRSpecNotificationsListComplete
        def notify(event, *args)
          return super if caller_locations(1, 1).first.label =~ /publish/
          return super if RSPEC_NOTIFICATIONS.include?(event)

          raise "#{event.inspect} must be added to `RSPEC_NOTIFICATIONS`"
        end
      end

      prepend EnforceRSpecNotificationsListComplete
    end
  end
end
