require "spec_helper"

describe "should start_with" do

  context "strings" do
    subject { "A test string" }

    it "passes if it matches the start of the string" do
      subject.should start_with "A test"
    end

    it "fails if it does not match the start of the string" do
      lambda {
        subject.should start_with "Something"
      }.should fail_with("expected 'A test string' to start with 'Something'")
    end
  end
end

describe "should end_with" do

  context "strings" do
    subject { "A test string" }

    it "passes if it matches the end of the string" do
      subject.should end_with "string"
    end

    it "fails if it does not match the end of the string" do
      lambda {
        subject.should end_with "Something"
      }.should fail_with("expected 'A test string' to end with 'Something'")
    end
  end
end

describe "should_not start_with" do

  context "strings" do
    subject { "A test string" }

    it "passes if it does not match the start of the string" do
      subject.should_not start_with "Something"
    end

    it "fails if it does match the start of the string" do
      lambda {
        subject.should_not start_with "A test"
      }.should fail_with("expected 'A test string' not to start with 'A test'")
    end
  end
end

describe "should_not end_with" do

  context "strings" do
    subject { "A test string" }

    it "passes if it does not match the end of the string" do
      subject.should_not end_with "Something"
    end

    it "fails if it matches the end of the string" do
      lambda {
        subject.should_not end_with "string"
      }.should fail_with("expected 'A test string' not to end with 'string'")

    end
  end
end
