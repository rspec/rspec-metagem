require "spec_helper"

describe "should start_with" do

  context "A test string" do
    it "passes if it matches the start of the string" do
      subject.should start_with "A test"
    end

    it "fails if it does not match the start of the string" do
      lambda {
        subject.should start_with "Something"
      }.should fail_with("expected \"A test string\" to start with \"Something\"")
    end
  end

  context [0, 1, 2, 3, 4] do
    it "passes if it is the first element of the array" do
       subject.should start_with 0
    end

    it "passes if the first elements of the array match" do
      subject.should start_with [0, 1]
    end

    it "fails if it does not match the first element of the array" do
      lambda {
        subject.should start_with "Something"
      }.should fail_with("expected [0, 1, 2, 3, 4] to start with \"Something\"")
    end

    it "fails if it the first elements of the array do not match" do
      lambda {
        subject.should start_with [1, 2]
      }.should fail_with("expected [0, 1, 2, 3, 4] to start with [1, 2]")
    end
  end
end

describe "should_not start_with" do

  context "A test string" do
    it "passes if it does not match the start of the string" do
      subject.should_not start_with "Something"
    end

    it "fails if it does match the start of the string" do
      lambda {
        subject.should_not start_with "A test"
      }.should fail_with("expected \"A test string\" not to start with \"A test\"")
    end
  end

  context [0, 1, 2, 3, 4] do
    it "passes if it is not the first element of the array" do
       subject.should_not start_with "Something"
    end

    it "passes if the first elements of the array do not match" do
      subject.should_not start_with [1, 2]
    end

    it "fails if it matches the first element of the array" do
      lambda {
        subject.should_not start_with 0
      }.should fail_with("expected [0, 1, 2, 3, 4] not to start with 0")
    end

    it "fails if it the first elements of the array match" do
      lambda {
        subject.should_not start_with [0, 1]
      }.should fail_with("expected [0, 1, 2, 3, 4] not to start with [0, 1]")
    end
  end
end

describe "should end_with" do

  context "A test string" do
    it "passes if it matches the end of the string" do
      subject.should end_with "string"
    end

    it "fails if it does not match the end of the string" do
      lambda {
        subject.should end_with "Something"
      }.should fail_with("expected \"A test string\" to end with \"Something\"")
    end
  end

  context [0, 1, 2, 3, 4] do
    it "passes if it is the last element of the array" do
       subject.should end_with 4
    end

    it "passes if the last elements of the array match" do
      subject.should end_with [3, 4]
    end

    it "fails if it does not match the last element of the array" do
      lambda {
        subject.should end_with "Something"
      }.should fail_with("expected [0, 1, 2, 3, 4] to end with \"Something\"")
    end

    it "fails if it the last elements of the array do not match" do
      lambda {
        subject.should end_with [1, 2]
      }.should fail_with("expected [0, 1, 2, 3, 4] to end with [1, 2]")
    end
  end
end

describe "should_not end_with" do

  context "A test string" do
    it "passes if it does not match the end of the string" do
      subject.should_not end_with "Something"
    end

    it "fails if it matches the end of the string" do
      lambda {
        subject.should_not end_with "string"
      }.should fail_with("expected \"A test string\" not to end with \"string\"")

    end
  end

  context [0, 1, 2, 3, 4] do
    it "passes if it is not the last element of the array" do
       subject.should_not end_with "Something"
    end

    it "passes if the last elements of the array do not match" do
      subject.should_not end_with [0, 1]
    end

    it "fails if it matches the last element of the array" do
      lambda {
        subject.should_not end_with 4
      }.should fail_with("expected [0, 1, 2, 3, 4] not to end with 4")
    end

    it "fails if it the last elements of the array match" do
      lambda {
        subject.should_not end_with [3, 4]
      }.should fail_with("expected [0, 1, 2, 3, 4] not to end with [3, 4]")
    end

  end
end