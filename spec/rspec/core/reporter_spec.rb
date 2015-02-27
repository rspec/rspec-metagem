module RSpec::Core
  RSpec.describe Reporter do
    include FormatterSupport

    let(:config)   { Configuration.new }
    let(:reporter) { Reporter.new config }
    let(:start_time) { Time.now }
    let(:example) { super() }

    describe "finish" do
      let(:formatter) { double("formatter") }

      %w[start_dump dump_pending dump_failures dump_summary close].map(&:to_sym).each do |message|
        it "sends #{message} to the formatter(s) that respond to message" do
          reporter.register_listener formatter, message
          expect(formatter.as_null_object).to receive(message)
          reporter.finish
        end

        it "doesnt notify formatters about messages they dont implement" do
          expect { reporter.finish }.to_not raise_error
        end
      end

      it "dumps the failure summary after the profile and deprecation summary so failures don't scroll off the screen and get missed" do
        config.profile_examples = 10
        formatter = instance_double("RSpec::Core::Formatter::ProgressFormatter")
        reporter.register_listener(formatter, :dump_summary, :dump_profile, :deprecation_summary)

        expect(formatter).to receive(:deprecation_summary).ordered
        expect(formatter).to receive(:dump_profile).ordered
        expect(formatter).to receive(:dump_summary).ordered

        reporter.finish
      end
    end

    describe 'start' do
      before { config.start_time = start_time }

      it 'notifies the formatter of start with example count' do
        formatter = double("formatter")
        reporter.register_listener formatter, :start

        expect(formatter).to receive(:start) do |notification|
          expect(notification.count).to eq 3
          expect(notification.load_time).to eq 5
        end

        reporter.start 3, (start_time + 5)
      end

      it 'notifies the formatter of the seed used before notifing of start' do
        formatter = double("formatter")
        reporter.register_listener formatter, :seed
        reporter.register_listener formatter, :start
        expect(formatter).to receive(:seed).ordered.with(
          an_object_having_attributes(:seed => config.seed, :seed_used? => config.seed_used?)
        )
        expect(formatter).to receive(:start).ordered
        reporter.start 1
      end
    end

    context "given one formatter" do
      it "passes messages to that formatter" do
        formatter = double("formatter", :example_started => nil)
        reporter.register_listener formatter, :example_started
        example = new_example

        expect(formatter).to receive(:example_started) do |notification|
          expect(notification.example).to eq example
        end

        reporter.example_started(example)
      end

      it "passes example_group_started and example_group_finished messages to that formatter in that order" do
        order = []

        formatter = double("formatter")
        allow(formatter).to receive(:example_group_started)  { |n| order << "Started: #{n.group.description}" }
        allow(formatter).to receive(:example_group_finished) { |n| order << "Finished: #{n.group.description}" }

        reporter.register_listener formatter, :example_group_started, :example_group_finished

        group = RSpec.describe("root")
        group.describe("context 1") do
          example("ignore") {}
        end
        group.describe("context 2") do
          example("ignore") {}
        end

        group.run(reporter)

        expect(order).to eq([
           "Started: root",
           "Started: context 1",
           "Finished: context 1",
           "Started: context 2",
           "Finished: context 2",
           "Finished: root"
        ])
      end
    end

    context "given an example group with no examples" do
      it "does not pass example_group_started or example_group_finished to formatter" do
        formatter = double("formatter")
        expect(formatter).not_to receive(:example_group_started)
        expect(formatter).not_to receive(:example_group_finished)

        reporter.register_listener formatter, :example_group_started, :example_group_finished

        group = RSpec.describe("root")

        group.run(reporter)
      end
    end

    context "given multiple formatters" do
      it "passes messages to all formatters" do
        formatters = (1..2).map { double("formatter", :example_started => nil) }
        example = new_example

        formatters.each do |formatter|
          expect(formatter).to receive(:example_started) do |notification|
            expect(notification.example).to eq example
          end
          reporter.register_listener formatter, :example_started
        end

        reporter.example_started(example)
      end
    end

    describe "#report" do
      it "supports one arg (count)" do
        reporter.report(1) {}
      end

      it "yields itself" do
        yielded = nil
        reporter.report(3) { |r| yielded = r }
        expect(yielded).to eq(reporter)
      end
    end

    describe "#register_listener" do
      let(:listener) { double("listener", :start => nil) }

      before { reporter.register_listener listener, :start }

      it 'will register the listener to specified notifications' do
        expect(reporter.registered_listeners :start).to eq [listener]
      end

      it 'will match string notification names' do
        reporter.register_listener listener, "stop"
        expect(reporter.registered_listeners :stop).to eq [listener]
      end

      it 'will send notifications when a subscribed event is triggered' do
        expect(listener).to receive(:start) do |notification|
          expect(notification.count).to eq 42
        end
        reporter.start 42
      end

      it 'will ignore duplicated listeners' do
        reporter.register_listener listener, :start
        expect(listener).to receive(:start).once
        reporter.start 42
      end
    end

    describe "#publish" do
      let(:listener) { double("listener", :custom => nil) }
      before do
        reporter.register_listener listener, :custom, :start
      end

      it 'will send custom events to registered listeners' do
        expect(listener).to receive(:custom).with(RSpec::Core::Notifications::NullNotification)
        reporter.publish :custom
      end

      it 'will raise when encountering RSpec standard events' do
        expect { reporter.publish :start }.to raise_error(
          StandardError,
          a_string_including("not internal RSpec ones")
        )
      end

      it 'will ignore event names sent as strings' do
        expect(listener).not_to receive(:custom)
        reporter.publish "custom"
      end

      it 'will provide a custom notification object based on the options hash' do
        expect(listener).to receive(:custom).with(
          an_object_having_attributes(:my_data => :value)
        )
        reporter.publish :custom, :my_data => :value
      end
    end

    describe "timing" do
      before do
        config.start_time = start_time
      end

      it "uses RSpec::Core::Time as to not be affected by changes to time in examples" do
        formatter = double(:formatter)
        reporter.register_listener formatter, :dump_summary
        reporter.start 1
        allow(Time).to receive_messages(:now => ::Time.utc(2012, 10, 1))

        duration = nil
        allow(formatter).to receive(:dump_summary) do |notification|
          duration = notification.duration
        end

        reporter.finish
        expect(duration).to be < 0.2
      end

      it "captures the load time so it can report it later" do
        formatter = instance_double("ProgressFormatter")
        reporter.register_listener formatter, :dump_summary
        reporter.start 3, (start_time + 5)

        expect(formatter).to receive(:dump_summary) do |notification|
          expect(notification.load_time).to eq(5)
        end

        reporter.finish
      end
    end
  end
end
