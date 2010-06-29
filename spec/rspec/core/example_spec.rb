require 'spec_helper'

describe RSpec::Core::Example, :parent_metadata => 'sample' do
  let(:example_group) do
    RSpec::Core::ExampleGroup.describe('group description')
  end

  let(:example_instance) do
    example_group.example('example description')
  end

  describe "#behaviour" do
    it "is deprecated" do
      RSpec.should_receive(:deprecate)
      example_instance.behaviour
    end
  end

  describe '#inspect' do
    it "should return 'group description - description'" do
      example_instance.inspect.should == 'group description example description'
    end
  end

  describe '#to_s' do
    it "should return #inspect" do
      example_instance.to_s.should == example_instance.inspect
    end
  end

  describe '#described_class' do
    it "returns the class (if any) of the outermost example group" do
      described_class.should == RSpec::Core::Example
    end
  end

  describe "accessing metadata within a running example" do
    it "should have a reference to itself when running" do
      example.description.should == "should have a reference to itself when running"
    end

    it "should be able to access the example group's top level metadata as if it were its own" do
      example.example_group.metadata.should include(:parent_metadata => 'sample')
      example.metadata.should include(:parent_metadata => 'sample')
    end
  end

  describe "accessing options within a running example" do
    it "should be able to look up option values by key", :demo => :data do
      example.options[:demo].should == :data
    end
  end

  describe "#run" do
    it "runs after(:each) when the example passes" do
      after_run = false
      group = RSpec::Core::ExampleGroup.describe do
        after(:each) { after_run = true }
        example('example') { 1.should == 1 }
      end
      group.run_all
      after_run.should be_true, "expected after(:each) to be run"
    end

    it "runs after(:each) when the example fails" do
      after_run = false
      group = RSpec::Core::ExampleGroup.describe do
        after(:each) { after_run = true }
        example('example') { 1.should == 2 }
      end
      group.run_all
      after_run.should be_true, "expected after(:each) to be run"
    end

    it "runs after(:each) when the example raises an Exception" do
      after_run = false
      group = RSpec::Core::ExampleGroup.describe do
        after(:each) { after_run = true }
        example('example') { raise "this error" }
      end
      group.run_all
      after_run.should be_true, "expected after(:each) to be run"
    end

    it "wraps before/after(:each) inside around" do
      results = []
      group = RSpec::Core::ExampleGroup.describe do
        around(:each) do |e|
          results << "around (before)"
          e.run
          results << "around (after)"
        end
        before(:each) { results << "before" }
        after(:each) { results << "after" }
        example { results << "example" }
      end

      group.run_all
      results.should eq([
        "around (before)",
        "before",
        "example",
        "after",
        "around (after)"
      ])
    end
  end

  describe "#in_block?" do
    before do
      example.should_not be_in_block
    end
    it "is only true during the example (but not before or after)" do
      example.should be_in_block
    end
    after do
      example.should_not be_in_block
    end
  end
end
