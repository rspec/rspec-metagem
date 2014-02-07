require 'spec_helper'
require 'rspec/core/formatters/legacy_formatter'
require 'support/old_style_formatter_example'
require 'support/legacy_formatter_using_sub_classing_example'

RSpec.describe RSpec::Core::Formatters::LegacyFormatter do
  include FormatterSupport

  it 'can access attributes provided by base class accessors in #initialize' do
    klass = Class.new(LegacyFormatterUsingSubClassing) do
      def initialize(*args)
        example_count
        super
      end
    end

    config.add_formatter klass
    expect(config.formatters.first).to be_a(RSpec::Core::Formatters::LegacyFormatter)
    expect(config.formatters.first.formatter).to be_a(klass)
  end

  [OldStyleFormatterExample, LegacyFormatterUsingSubClassing].each do |klass|

    describe "#{klass}" do
      let(:described_class) { klass }

      describe "#start" do
        it "notifies formatter of start" do
          send_notification :start, count_notification(5)
          expect(output.string).to include "Started 5 examples"
        end
      end

      describe "#example_group_started" do
        it "notifies formatter of example_group_started" do
          send_notification :example_group_started, group_notification
          expect(output.string).to include "Started Group"
        end
      end

      describe "#example_group_finished" do
        it "notifies formatter of example_group_finished" do
          send_notification :example_group_finished, group_notification
          expect(output.string).to include "Finished Group"
        end
      end

      describe "#example_started" do
        it "notifies formatter of example_started" do
          send_notification :example_started, example_notification
          expect(output.string).to include "Started Example"
        end
      end

      describe "#example_passed" do
        it "notifies formatter of example_passed" do
          send_notification :example_passed, example_notification
          expect(output.string).to include "."
        end
      end

      describe "#example_pending" do
        it "notifies formatter of example_pending" do
          send_notification :example_pending, example_notification
          expect(output.string).to include "P"
        end
      end

      describe "#example_failed" do
        it "notifies formatter of example_failed" do
          send_notification :example_failed, example_notification
          expect(output.string).to include "F"
        end
      end

      describe "#message" do
        it "notifies formatter of message" do
          send_notification :message, message_notification("A Message")
          expect(output.string).to include "A Message"
        end
      end

      describe "#stop" do
        it "notifies formatter of stop" do
          send_notification :stop, null_notification
          expect(output.string).to include "Stopped"
        end
      end

      describe "#start_dump" do
        it "notifies formatter of start_dump" do
          send_notification :start_dump, null_notification
          expect(output.string).to include "Dumping!"
        end
      end

      describe "#dump_failures" do
        it "notifies formatter of dump_failures" do
          send_notification :dump_failures, null_notification
          expect(output.string).to include "Failures:"
        end
      end

      describe "#dump_summary" do
        it "notifies formatter of dump_summary" do
          duration, count, failures, pending = 3.5, 10, 3, 2
          send_notification :dump_summary, summary_notification(duration, count, failures, pending)
          expect(output.string).to(
                match("Finished in 3.5").
            and match("3/10 failed.").
            and match("2 pending.")
          )
        end
      end

      describe "#dump_pending" do
        it "notifies formatter of dump_pending" do
          send_notification :dump_pending, null_notification
          expect(output.string).to match "Pending:"
        end
      end

      describe "#seed" do
        it "notifies formatter of seed" do
          send_notification :seed, seed_notification(17)
          expect(output.string).to match "Randomized with seed 17"
        end
      end

      describe "#close" do
        it "notifies formatter of close" do
          send_notification :close, null_notification
        end
      end
    end
  end
end
