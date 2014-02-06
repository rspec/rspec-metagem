require 'spec_helper'
require 'rspec/core/formatters/progress_formatter'

RSpec.describe RSpec::Core::Formatters::ProgressFormatter do
  include FormatterSupport

  before do
    send_notification :start, count_notification(2)
    allow(formatter).to receive(:color_enabled?).and_return(false)
  end

  it 'prints a . on example_passed' do
    send_notification :example_passed, example_notification
    expect(output.string).to eq(".")
  end

  it 'prints a * on example_pending' do
    send_notification :example_pending, example_notification
    expect(output.string).to eq("*")
  end

  it 'prints a F on example_failed' do
    send_notification :example_failed, example_notification
    expect(output.string).to eq("F")
  end

  it "produces standard summary without pending when pending has a 0 count" do
    send_notification :dump_summary, summary_notification(0.00001, 2, 0, 0)
    expect(output.string).to match(/^\n/)
    expect(output.string).to match(/2 examples, 0 failures/i)
    expect(output.string).not_to match(/0 pending/i)
  end

  it "pushes nothing on start" do
    #start already sent
    expect(output.string).to eq("")
  end

  it "pushes nothing on start dump" do
    send_notification :start_dump, null_notification
    expect(output.string).to eq("\n")
  end
end
