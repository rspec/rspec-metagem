require "spec_helper"

module RSpec::Core
  describe Reporter do
    context "given one formatter" do
      it "passes messages to that formatter" do
        formatter = double("formatter")
        example = double("example")
        reporter = Reporter.new(formatter)

        formatter.should_receive(:example_started).
          with(example)

        reporter.example_started(example)
      end

      it "passes example_group_started and example_group_finished messages to that formatter in that order" do
        order = []

        formatter = stub("formatter")
        formatter.stub(:example_group_started) { |group| order << "Started: #{group.description}" }
        formatter.stub(:example_group_finished) { |group| order << "Finished: #{group.description}" }

        group = ExampleGroup.describe("root")
        group.describe("context 1")
        group.describe("context 2")

        group.run_all(Reporter.new(formatter))

        order.should == [
           "Started: root",
           "Started: context 1",
           "Finished: context 1",
           "Started: context 2",
           "Finished: context 2",
           "Finished: root"
        ]
      end
    end

    context "given multiple formatters" do
      it "passes messages to all formatters" do
        formatters = [double("formatter"), double("formatter")]
        example = double("example")
        reporter = Reporter.new(*formatters)

        formatters.each do |formatter|
          formatter.
            should_receive(:example_started).
            with(example)
        end

        reporter.example_started(example)
      end
    end
  end
end
