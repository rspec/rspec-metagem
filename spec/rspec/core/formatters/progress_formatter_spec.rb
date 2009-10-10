require 'spec_helper'

describe Rspec::Core::Formatters::ProgressFormatter do
  
   before do
     @output = StringIO.new
     @formatter = Rspec::Core::Formatters::ProgressFormatter.new
     @formatter.start(2)
     @formatter.stub!(:color_enabled?).and_return(false)
     @formatter.stub!(:output).and_return(@output)
   end
   
   it "should produce line break on start dump" do
     @formatter.start_dump(3)
     @output.string.should == "\n"
   end
   
   it "should produce standard summary without pending when pending has a 0 count" do
     @formatter.start_dump(3)
     @formatter.dump_summary
     @output.string.should =~ /Finished in 3 seconds\n2 examples/i
   end
   
   it "should push nothing on start" do
     @formatter.start(4)
     @output.string.should == ""
   end
   
end
