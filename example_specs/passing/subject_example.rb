require File.dirname(__FILE__) + '/spec_helper'

module SubjectExample
  class OneThing
    attr_accessor :what_things_do
    def initialize
      self.what_things_do = "stuff"
    end
  end

  # implicit subject
  describe OneThing do
    it "should do what things do" do
      subject.what_things_do.should == "stuff"
    end
    it "should be a OneThing" do
      should == subject
    end
    its(:what_things_do) { should == "stuff" }
  end

  # explicit subject
  describe SubjectExample::OneThing do
    subject { SubjectExample::OneThing.new }
    it "should do what things do" do
      subject.what_things_do.should == "stuff"
    end
    it "should be a OneThing" do
      should == subject
    end
    its(:what_things_do) { should == "stuff" }
  end

  # modified subject
  describe OneThing do
    subject { SubjectExample::OneThing.new }
    before { subject.what_things_do = "more stuff" }
    it "should do what things do" do
      subject.what_things_do.should == "more stuff"
    end
    its(:what_things_do) { should == "more stuff" }
  end

end

