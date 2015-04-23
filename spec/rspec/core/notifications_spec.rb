require 'rspec/core/notifications'

RSpec.describe "FailedExampleNotification" do
  include FormatterSupport

  let(:example) { new_example }
  exception_line = __LINE__ + 1
  let(:exception) { instance_double(Exception, :backtrace => [ "#{__FILE__}:#{exception_line}"], :message => 'Test exception') }
  let(:notification) { ::RSpec::Core::Notifications::FailedExampleNotification.new(example) }

  before do
    allow(example.execution_result).to receive(:exception) { exception }
    example.metadata[:absolute_file_path] = __FILE__
  end

  it 'provides a description' do
    expect(notification.description).to eq(example.full_description)
  end

  it 'provides `colorized_formatted_backtrace`, which formats the backtrace and colorizes it' do
    allow(RSpec.configuration).to receive(:color_enabled?).and_return(true)
    expect(notification.colorized_formatted_backtrace).to eq(["\e[36m# #{RSpec::Core::Metadata.relative_path(__FILE__)}:#{exception_line}\e[0m"])
  end

  describe '#message_lines' do
    let(:example_group) { class_double(RSpec::Core::ExampleGroup, :metadata => {}, :parent_groups => [], :location => "#{__FILE__}:#{__LINE__}") }

    before do
      allow(example).to receive(:example_group) { example_group }
    end

    it 'should return failure_lines without color' do
      lines = notification.message_lines
      expect(lines[0]).to match %r{\AFailure\/Error}
      expect(lines[1]).to match %r{\A\s*Test exception\z}
    end

    it 'returns failures_lines without color when they are part of a shared example group' do
      example.metadata[:shared_group_inclusion_backtrace] <<
        RSpec::Core::SharedExampleGroupInclusionStackFrame.new("foo", "bar")

      lines = notification.message_lines
      expect(lines[0]).to match %r{\AFailure\/Error}
      expect(lines[1]).to match %r{\A\s*Test exception\z}
    end

    if String.method_defined?(:encoding)
      it "returns failures_lines with invalid bytes replace by '?'" do
        message_with_invalid_byte_sequence =
          "\xEF \255 \xAD I have bad bytes".force_encoding(Encoding::UTF_8)
        allow(exception).to receive(:message).
          and_return(message_with_invalid_byte_sequence)

        lines = notification.message_lines
        expect(lines[0]).to match %r{\AFailure\/Error}
        expect(lines[1].strip).to eq("? ? ? I have bad bytes")
      end
    end
  end
end

module RSpec::Core::Notifications
  RSpec.describe ExamplesNotification do
    include FormatterSupport

    describe "#notifications" do
      it 'returns an array of notification objects for all the examples' do
        reporter = RSpec::Core::Reporter.new(RSpec.configuration)
        example = new_example

        reporter.example_started(example)
        reporter.example_passed(example)

        notification = ExamplesNotification.new(reporter)
        expect(notification.notifications).to match [
          an_instance_of(ExampleNotification) & an_object_having_attributes(:example => example)
        ]
      end
    end
  end
end
