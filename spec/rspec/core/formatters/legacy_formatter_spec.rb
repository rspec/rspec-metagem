require 'spec_helper'
require 'rspec/core/formatters/legacy_formatter'

RSpec.describe RSpec::Core::Formatters::LegacyFormatter do

  let(:formatter)     { RSpec::Core::Formatters::LegacyFormatter.new(old_formatter) }
  let(:old_formatter) { double "a legacy formatter" }

  describe '#notifications' do
    before { allow(old_formatter).to receive_messages(:start => nil, :other_method => nil) }

    it "lists notifications the formatter responds to from the old set" do
      expect(formatter.notifications).to eq([:start])
    end
  end

  describe "#start" do
    let(:example_count) { double "count" }

    it "notifies formatter of start" do
      expect(old_formatter).to receive(:start).with(example_count)
      formatter.start example_count
    end
  end

  describe "#example_group_started" do
    let(:group) { double "group" }

    it "notifies formatter of example_group_started" do
      expect(old_formatter).to receive(:example_group_started).with(group)
      formatter.example_group_started group
    end
  end

  describe "#example_group_finished" do
    let(:group) { double "group" }

    it "notifies formatter of example_group_finished" do
      expect(old_formatter).to receive(:example_group_finished).with(group)
      formatter.example_group_finished group
    end
  end

  describe "#example_started" do
    let(:example) { double "example" }

    it "notifies formatter of example_started" do
      expect(old_formatter).to receive(:example_started).with(example)
      formatter.example_started example
    end
  end

  describe "#example_passed" do
    let(:example) { double "example" }

    it "notifies formatter of example_passed" do
      expect(old_formatter).to receive(:example_passed).with(example)
      formatter.example_passed example
    end
  end

  describe "#example_pending" do
    let(:example) { double "example" }

    it "notifies formatter of example_pending" do
      expect(old_formatter).to receive(:example_pending).with(example)
      formatter.example_pending example
    end
  end

  describe "#example_failed" do
    let(:example) { double "example" }

    it "notifies formatter of example_failed" do
      expect(old_formatter).to receive(:example_failed).with(example)
      formatter.example_failed example
    end
  end

  describe "#message" do
    let(:message) { double "message" }

    it "notifies formatter of message" do
      expect(old_formatter).to receive(:message).with(message)
      formatter.message message
    end
  end

  describe "#stop" do
    it "notifies formatter of stop" do
      expect(old_formatter).to receive(:stop)
      formatter.stop
    end
  end

  describe "#start_dump" do
    it "notifies formatter of start_dump" do
      expect(old_formatter).to receive(:start_dump)
      formatter.start_dump
    end
  end

  describe "#dump_failures" do
    it "notifies formatter of dump_failures" do
      expect(old_formatter).to receive(:dump_failures)
      formatter.dump_failures
    end
  end

  describe "#dump_summary" do
    %w[duration count failures pending].each_with_index do |name, value|
      let(name) { value }
    end

    it "notifies formatter of dump_summary" do
      expect(old_formatter).to receive(:dump_summary).with(duration, count, failures, pending)
      formatter.dump_summary duration, count, failures, pending
    end
  end

  describe "#dump_pending" do
    it "notifies formatter of dump_pending" do
      expect(old_formatter).to receive(:dump_pending)
      formatter.dump_pending
    end
  end

  describe "#dump_profile" do
    it "notifies formatter of dump_profile" do
      expect(old_formatter).to receive(:dump_profile)
      formatter.dump_profile
    end
  end

  describe "#seed" do
    let(:seed) { double "seed" }

    it "notifies formatter of seed" do
      expect(old_formatter).to receive(:seed).with(seed)
      formatter.seed seed
    end
  end

  describe "#close" do
    it "notifies formatter of close" do
      expect(old_formatter).to receive(:close)
      formatter.close
    end
  end
end
