require 'spec_helper'
require 'rspec/core/formatters/legacy_formatter'
require 'support/old_style_formatter_example'

RSpec.describe RSpec::Core::Formatters::LegacyFormatter do
  include FormatterSupport

  let(:described_class) { OldStyleFormatterExample }

  describe "#start" do
    it "notifies formatter of start" do
      send_notification :start, double(count: 5)
      expect(output.string).to include "Started 5 examples"
    end
  end

  describe "#example_group_started" do
    let(:group) { class_double "RSpec::Core::ExampleGroup", :description => "Group" }

    it "notifies formatter of example_group_started" do
      send_notification :example_group_started, double(group: group)
      expect(output.string).to include "Started Group"
    end
  end

  describe "#example_group_finished" do
    let(:group) { class_double "RSpec::Core::ExampleGroup", :description => "Group" }

    it "notifies formatter of example_group_finished" do
      send_notification :example_group_finished, double(group: group)
      expect(output.string).to include "Finished Group"
    end
  end

  describe "#example_started" do
    let(:example) { instance_double "RSpec::Core::Example", :full_description => "Example" }

    it "notifies formatter of example_started" do
      send_notification :example_started, double(example: example)
      expect(output.string).to include "Started Example"
    end
  end

  describe "#example_passed" do
    let(:example) { double "example" }

    it "notifies formatter of example_passed" do
      send_notification :example_passed, double(example: example)
      expect(output.string).to include "."
    end
  end

  describe "#example_pending" do
    let(:example) { double "example" }

    it "notifies formatter of example_pending" do
      send_notification :example_pending, double(example: example)
      expect(output.string).to include "P"
    end
  end

  describe "#example_failed" do
    let(:example) { double "example" }

    it "notifies formatter of example_failed" do
      send_notification :example_failed, double(example: example)
      expect(output.string).to include "F"
    end
  end

  describe "#message" do
    it "notifies formatter of message" do
      send_notification :message, double(message: "A Message")
      expect(output.string).to include "A Message"
    end
  end

  describe "#stop" do
    it "notifies formatter of stop" do
      send_notification :stop, double
      expect(output.string).to include "Stopped"
    end
  end

  describe "#start_dump" do
    it "notifies formatter of start_dump" do
      send_notification :start_dump, double
      expect(output.string).to include "Dumping!"
    end
  end

  describe "#dump_failures" do
    it "notifies formatter of dump_failures" do
      send_notification :dump_failures, double
      expect(output.string).to include "Failures:"
    end
  end

  describe "#dump_summary" do
    it "notifies formatter of dump_summary" do
      duration, count, failures, pending = 3.5, 10, 3, 2
      send_notification :dump_summary, RSpec::Core::Reporter::SummaryNotification.new(duration, count, failures, pending)
      expect(output.string).to match "Finished in 3.5"
      expect(output.string).to match "3/10 failed."
      expect(output.string).to match "2 pending."
    end
  end

  describe "#dump_pending" do
    it "notifies formatter of dump_pending" do
      send_notification :dump_pending, double
      expect(output.string).to match "Pending:"
    end
  end

  describe "#seed" do
    it "notifies formatter of seed" do
      send_notification :seed, double(seed: 17)
      expect(output.string).to match "Randomized with seed 17"
    end
  end

  describe "#close" do
    it "notifies formatter of close" do
      send_notification :close, double
    end
  end
end
