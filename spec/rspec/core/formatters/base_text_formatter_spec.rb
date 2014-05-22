require 'spec_helper'
require 'rspec/core/formatters/base_text_formatter'

RSpec.describe RSpec::Core::Formatters::BaseTextFormatter do
  include FormatterSupport

  context "when closing the formatter", :isolated_directory => true do
    it 'does not close an already closed output stream' do
      output = File.new("./output_to_close", "w")
      formatter = described_class.new(output)
      output.close

      expect { formatter.close(RSpec::Core::Notifications::NullNotification) }.not_to raise_error
    end
  end

  describe "#dump_summary" do
    it "with 0s outputs pluralized (excluding pending)" do
      send_notification :dump_summary, summary_notification(0, [], [], [], 0)
      expect(output.string).to match("0 examples, 0 failures")
    end

    it "with 1s outputs singular (including pending)" do
      send_notification :dump_summary, summary_notification(0, examples(1), examples(1), examples(1), 0)
      expect(output.string).to match("1 example, 1 failure, 1 pending")
    end

    it "with 2s outputs pluralized (including pending)" do
      send_notification :dump_summary, summary_notification(2, examples(2), examples(2), examples(2), 0)
      expect(output.string).to match("2 examples, 2 failures, 2 pending")
    end

    it "includes command to re-run each failed example" do
      group = RSpec::Core::ExampleGroup.describe("example group") do
        it("fails") { fail }
      end
      line = __LINE__ - 2
      group.run(reporter)
      examples = group.examples
      send_notification :dump_summary, summary_notification(1, examples, examples, [], 0)
      expect(output.string).to include("rspec #{RSpec::Core::Metadata::relative_path("#{__FILE__}:#{line}")} # example group fails")
    end
  end

  describe "#dump_failures" do
    let(:group) { RSpec::Core::ExampleGroup.describe("group name") }

    before { allow(RSpec.configuration).to receive(:color_enabled?) { false } }

    def run_all_and_dump_failures
      group.run(reporter)
      send_notification :dump_failures, failed_examples_notification
    end

    it "preserves formatting" do
      group.example("example name") { expect("this").to eq("that") }

      run_all_and_dump_failures

      expect(output.string).to match(/group name example name/m)
      expect(output.string).to match(/(\s+)expected: \"that\"\n\1     got: \"this\"/m)
    end

    context "with an exception without a message" do
      it "does not throw NoMethodError" do
        exception_without_message = Exception.new()
        allow(exception_without_message).to receive(:message) { nil }
        group.example("example name") { raise exception_without_message }
        expect { run_all_and_dump_failures }.not_to raise_error
      end

      it "preserves ancestry" do
        example = group.example("example name") { raise "something" }
        run_all_and_dump_failures
        expect(example.example_group.parent_groups.size).to eq 1
      end
    end

    context "with an exception that has an exception instance as its message" do
      it "does not raise NoMethodError" do
        gonzo_exception = RuntimeError.new
        allow(gonzo_exception).to receive(:message) { gonzo_exception }
        group.example("example name") { raise gonzo_exception }
        expect { run_all_and_dump_failures }.not_to raise_error
      end
    end

    context "with an instance of an anonymous exception class" do
      it "substitutes '(anonymous error class)' for the missing class name" do
        exception = Class.new(StandardError).new
        group.example("example name") { raise exception }
        run_all_and_dump_failures
        expect(output.string).to include('(anonymous error class)')
      end
    end

    context "with an exception class other than RSpec" do
      it "does not show the error class" do
        group.example("example name") { raise NameError.new('foo') }
        run_all_and_dump_failures
        expect(output.string).to match(/NameError/m)
      end
    end

    context "with a failed expectation (rspec-expectations)" do
      it "does not show the error class" do
        group.example("example name") { expect("this").to eq("that") }
        run_all_and_dump_failures
        expect(output.string).not_to match(/RSpec/m)
      end
    end

    context "with a failed message expectation (rspec-mocks)" do
      it "does not show the error class" do
        group.example("example name") { expect("this").to receive("that") }
        run_all_and_dump_failures
        expect(output.string).not_to match(/RSpec/m)
      end
    end

    context 'for #shared_examples' do
      it 'outputs the name and location' do
        group.shared_examples 'foo bar' do
          it("example name") { expect("this").to eq("that") }
        end

        line = __LINE__.next
        group.it_should_behave_like('foo bar')

        run_all_and_dump_failures

        expect(output.string).to include(
          'Shared Example Group: "foo bar" called from ' +
            "#{RSpec::Core::Metadata.relative_path(__FILE__)}:#{line}"
        )
      end

      context 'that contains nested example groups' do
        it 'outputs the name and location' do
          group.shared_examples 'foo bar' do
            describe 'nested group' do
              it("example name") { expect("this").to eq("that") }
            end
          end

          line = __LINE__.next
          group.it_should_behave_like('foo bar')

          run_all_and_dump_failures

          expect(output.string).to include(
            'Shared Example Group: "foo bar" called from ' +
              "./spec/rspec/core/formatters/base_text_formatter_spec.rb:#{line}"
          )
        end
      end
    end
  end

  describe "custom_colors" do
    it "uses the custom success color" do
      RSpec.configure do |config|
        config.color = true
        config.tty = true
        config.success_color = :cyan
      end
      send_notification :dump_summary, summary_notification(0, examples(1), [], [], 0)
      expect(output.string).to include("\e[36m")
    end
  end
end
