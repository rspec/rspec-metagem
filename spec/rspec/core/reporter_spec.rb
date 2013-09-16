require "spec_helper"

module RSpec::Core
  describe Reporter do
    let(:config) { Configuration.new }

    def reporter_for(*formatters)
      Reporter.new(config, *formatters)
    end

    describe "abort" do
      let(:formatter) { double("formatter") }
      let(:example)   { double("example") }
      let(:reporter)  { reporter_for(formatter) }

      %w[start_dump dump_pending dump_failures dump_summary close].each do |message|
        it "sends #{message} to the formatter(s) that respond to message" do
          formatter.as_null_object.should_receive(message)
          reporter.abort
        end

        it "doesnt notify formatters about messages they dont implement" do
          expect { reporter.abort }.to_not raise_error
        end
      end
    end

    context "given one formatter" do
      it "passes messages to that formatter" do
        formatter = double("formatter", :example_started => nil)
        example = double("example")
        reporter = reporter_for(formatter)

        formatter.should_receive(:example_started).
          with(example)

        reporter.example_started(example)
      end

      it "passes example_group_started and example_group_finished messages to that formatter in that order" do
        order = []

        formatter = double("formatter").as_null_object
        formatter.stub(:example_group_started) { |group| order << "Started: #{group.description}" }
        formatter.stub(:example_group_finished) { |group| order << "Finished: #{group.description}" }

        group = ExampleGroup.describe("root")
        group.describe("context 1") do
          example("ignore") {}
        end
        group.describe("context 2") do
          example("ignore") {}
        end

        group.run(reporter_for(formatter))

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
        formatter = double("formatter").as_null_object
        formatter.should_not_receive(:example_group_started)
        formatter.should_not_receive(:example_group_finished)

        group = ExampleGroup.describe("root")

        group.run(reporter_for(formatter))
      end
    end

    context "given multiple formatters" do
      it "passes messages to all formatters" do
        formatters = (1..2).map { double("formatter", :example_started => nil) }
        example = double("example")
        reporter = reporter_for(*formatters)

        formatters.each do |formatter|
          formatter.
            should_receive(:example_started).
            with(example)
        end

        reporter.example_started(example)
      end
    end

    describe "#report" do
      it "supports one arg (count)" do
        reporter_for.report(1) {}
      end

      it "yields itself" do
        reporter = reporter_for
        yielded = nil
        reporter.report(3) {|r| yielded = r}
        expect(yielded).to eq(reporter)
      end
    end

    describe "#register_listener" do
      let(:reporter) { reporter_for }
      let(:listener) { double("listener", :start => nil) }

      before { reporter.register_listener listener, :start }

      it 'will register the listener to specified notifications' do
        expect(reporter.registered_listeners :start).to eq [listener]
      end

      it 'will send notifications when a subscribed event is triggered' do
        listener.should_receive(:start).with(42)
        reporter.start 42
      end
    end

    describe "timing" do
      it "uses RSpec::Core::Time as to not be affected by changes to time in examples" do
        formatter = double(:formatter).as_null_object
        reporter = reporter_for formatter
        reporter.start 1
        Time.stub(:now => ::Time.utc(2012, 10, 1))

        duration = nil
        formatter.stub(:dump_summary) do |dur, _, _, _|
          duration = dur
        end

        reporter.finish
        expect(duration).to be < 0.2
      end
    end
  end
end
