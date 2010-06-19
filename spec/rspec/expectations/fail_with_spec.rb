require 'spec_helper'

describe RSpec::Expectations, "#fail_with with diff" do
  let(:differ) { double("differ") }

  before(:each) do
    RSpec::Expectations.stub(:differ) { differ }
  end
  
  it "does not call differ if no expected/actual" do
    lambda {
      RSpec::Expectations.fail_with "the message"
    }.should fail_with("the message")
  end
  
  it "calls differ if expected/actual are presented separately" do
    differ.should_receive(:diff_as_string).and_return("diff")
    lambda {
      RSpec::Expectations.fail_with "the message", "expected\nthis", "actual"
    }.should fail_with("the message\nDiff:diff")
  end
  
  it "does not call differ if expected/actual are single line strings" do
    differ.should_not_receive(:diff_as_string)
    RSpec::Expectations.fail_with("the message", "expected", "actual") rescue nil
  end
  
  it "calls differ if expected/actual are not strings" do
    differ.should_receive(:diff_as_object).and_return("diff")
    lambda {
      RSpec::Expectations.fail_with "the message", Object.new, Object.new
    }.should fail_with("the message\nDiff:diff")
  end
  
  it "does not call differ if expected or actual are procs" do
    differ.should_not_receive(:diff_as_string)
    differ.should_not_receive(:diff_as_object)
    lambda {
      RSpec::Expectations.fail_with "the message", lambda {}, lambda {}
    }.should fail_with("the message")
  end
end

