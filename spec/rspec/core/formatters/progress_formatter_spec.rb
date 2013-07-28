require 'spec_helper'
require 'rspec/core/formatters/progress_formatter'

RSpec.describe RSpec::Core::Formatters::ProgressFormatter do

  let(:output)    { StringIO.new }
  let(:formatter) { RSpec::Core::Formatters::ProgressFormatter.new output }

   before do
     formatter.start(2)
     allow(formatter).to receive(:color_enabled?).and_return(false)
   end

   it "lists its additional notifications" do
     expect(formatter.notifications).to include(
       :example_passed, :example_pending, :example_failed, :start_dump
      )
   end

   it "produces line break on start dump" do
     formatter.start_dump
     expect(output.string).to eq("\n")
   end

   it 'prints a . on example_passed' do
     formatter.example_passed double
     expect(output.string).to eq(".")
   end

   it 'prints a * on example_pending' do
     formatter.example_pending double
     expect(output.string).to eq("*")
   end

   it 'prints a F on example_failed' do
     formatter.example_failed double
     expect(output.string).to eq("F")
   end

   it "produces standard summary without pending when pending has a 0 count" do
     formatter.start_dump
     formatter.dump_summary(0.00001, 2, 0, 0)
     expect(output.string).to match(/2 examples, 0 failures/i)
     expect(output.string).not_to match(/0 pending/i)
   end

   it "pushes nothing on start" do
     formatter.start(4)
     expect(output.string).to eq("")
   end

end
