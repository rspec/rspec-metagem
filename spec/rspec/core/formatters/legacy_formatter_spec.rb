require 'spec_helper'
require 'rspec/core/formatters/console_codes'
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
          send_notification :start, start_notification(5)
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
          send_notification :dump_summary, summary_notification(duration, count, failures, pending, 0)
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

  describe LegacyFormatterUsingSubClassing do
    let(:legacy_formatter) { formatter.formatter }

    it "will lookup colour codes" do
      expect(legacy_formatter.color_code_for(:black)).to eq 30
    end

    it "will colorize text" do
      allow(RSpec.configuration).to receive(:color_enabled?) { true }
      expect(legacy_formatter.colorize("text", :black)).to eq "\e[30mtext\e[0m"
    end

    it "will colorize summary" do
      allow(RSpec.configuration).to receive(:color_enabled?) { true }
      expect(legacy_formatter.colorize_summary("text")).to include "\e[32mtext\e[0m"
    end

    it "allows access to the deprecated constants" do
      legacy_formatter
      expect_deprecation_with_call_site(__FILE__, __LINE__ + 1)
      expect(described_class::VT100_COLORS).to eq ::RSpec::Core::Formatters::ConsoleCodes::VT100_CODES
      expect_deprecation_with_call_site(__FILE__, __LINE__ + 1)
      expect(described_class::VT100_COLOR_CODES).to eq ::RSpec::Core::Formatters::ConsoleCodes::VT100_CODE_VALUES
    end

    ::RSpec::Core::Formatters::ConsoleCodes::VT100_CODES.each do |name, number|
      next if name == :black || name == :bold

      describe "##{name}" do
        before do
          allow(RSpec.configuration).to receive(:color_enabled?) { true }
          allow(RSpec).to receive(:deprecate)
        end

        it "prints the text using the color code for #{name}" do
          expect(legacy_formatter.send(name, "text")).to eq("\e[#{number}mtext\e[0m")
        end

        it "prints a deprecation warning" do
          expect(RSpec).to receive(:deprecate) {|*args|
            expect(args.first).to match(/#{name}/)
          }
          legacy_formatter.send(name, "text")
        end
      end
    end
  end
end
