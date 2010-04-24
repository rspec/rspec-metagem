require 'spec_helper'

class SelfObserver
  def self.cache
    @cache ||= []
  end

  def initialize
    self.class.cache << self
  end
end

module Rspec::Core

  describe ExampleGroup do

    describe '#describes' do

      context "with a constant as the first parameter" do

        it "is that constant" do
          ExampleGroup.describe(Object) { }.describes.should == Object
        end

      end

      context "with a string as the first parameter" do

        it "is nil" do
          ExampleGroup.describe("i'm a computer") { }.describes.should be_nil
        end

      end

    end

    describe '#description' do

      it "grabs the description from the metadata" do
        group = ExampleGroup.describe(Object, "my desc") { }
        group.description.should == group.metadata[:example_group][:description]
      end

    end

    describe '#metadata' do

      it "adds the third parameter to the metadata" do
        ExampleGroup.describe(Object, nil, 'foo' => 'bar') { }.metadata.should include({ "foo" => 'bar' })
      end

      it "adds the caller to metadata" do
        ExampleGroup.describe(Object) { }.metadata[:example_group][:caller].any? {|f|
          f =~ /#{__FILE__}/
        }.should be_true
      end

      it "adds the the file_path to metadata" do
        ExampleGroup.describe(Object) { }.metadata[:example_group][:file_path].should == __FILE__
      end

      it "has a reader for file_path" do
        ExampleGroup.describe(Object) { }.file_path.should == __FILE__
      end

      it "adds the line_number to metadata" do
        ExampleGroup.describe(Object) { }.metadata[:example_group][:line_number].should == __LINE__
      end

    end

    describe "before, after, and around hooks" do

      it "exposes the before each blocks at before_eachs" do
        group = ExampleGroup.describe
        group.before(:each) { 'foo' }
        group.should have(1).before_eachs
      end

      it "maintains the before each block order" do
        group = ExampleGroup.describe
        group.before(:each) { 15 }
        group.before(:each) { 'A' }
        group.before(:each) { 33.5 }

        group.before_eachs[0].call.should == 15
        group.before_eachs[1].call.should == 'A'
        group.before_eachs[2].call.should == 33.5
      end

      it "exposes the before all blocks at before_alls" do
        group = ExampleGroup.describe
        group.before(:all) { 'foo' }
        group.should have(1).before_alls
      end

      it "maintains the before all block order" do
        group = ExampleGroup.describe
        group.before(:all) { 15 }
        group.before(:all) { 'A' }
        group.before(:all) { 33.5 }

        group.before_alls[0].call.should == 15
        group.before_alls[1].call.should == 'A'
        group.before_alls[2].call.should == 33.5
      end

      it "exposes the after each blocks at after_eachs" do
        group = ExampleGroup.describe
        group.after(:each) { 'foo' }
        group.should have(1).after_eachs
      end

      it "maintains the after each block order" do
        group = ExampleGroup.describe
        group.after(:each) { 15 }
        group.after(:each) { 'A' }
        group.after(:each) { 33.5 }

        group.after_eachs[0].call.should == 15
        group.after_eachs[1].call.should == 'A'
        group.after_eachs[2].call.should == 33.5
      end

      it "exposes the after all blocks at after_alls" do
        group = ExampleGroup.describe
        group.after(:all) { 'foo' }
        group.should have(1).after_alls
      end

      it "maintains the after each block order" do
        group = ExampleGroup.describe
        group.after(:all) { 15 }
        group.after(:all) { 'A' }
        group.after(:all) { 33.5 }

        group.after_alls[0].call.should == 15
        group.after_alls[1].call.should == 'A'
        group.after_alls[2].call.should == 33.5
      end

      it "exposes the around each blocks at after_alls" do
        group = ExampleGroup.describe
        group.around(:each) { 'foo' }
        group.should have(1).around_eachs
      end
      
    end

    describe "adding examples" do

      it "allows adding an example using 'it'" do
        group = ExampleGroup.describe
        group.it("should do something") { }
        group.examples.size.should == 1
      end

      it "exposes all examples at examples" do
        group = ExampleGroup.describe
        group.it("should do something 1") { }
        group.it("should do something 2") { }
        group.it("should do something 3") { }
        group.examples.size.should == 3
      end

      it "maintains the example order" do
        group = ExampleGroup.describe
        group.it("should 1") { }
        group.it("should 2") { }
        group.it("should 3") { }
        group.examples[0].description.should == 'should 1'
        group.examples[1].description.should == 'should 2'
        group.examples[2].description.should == 'should 3'
      end

    end

    describe Object, "describing nested example_groups", :little_less_nested => 'yep' do 

      describe "A sample nested group", :nested_describe => "yep" do
        it "sets the described class to the constant Object" do
          running_example.example_group.describes.should == Object
        end

        it "sets the description to 'A sample nested describe'" do
          running_example.example_group.description.should == 'A sample nested group'
        end

        it "has top level metadata from the example_group and its ancestors" do
          running_example.example_group.metadata.should include(:little_less_nested => 'yep', :nested_describe => 'yep')
        end

        it "exposes the parent metadata to the contained examples" do
          running_example.metadata.should include(:little_less_nested => 'yep', :nested_describe => 'yep')
        end
      end

    end

    describe "#run_examples" do

      let(:reporter) { double("reporter").as_null_object }

      it "returns true if all examples pass" do
        group = ExampleGroup.describe('group') do
          example('ex 1') { 1.should == 1 }
          example('ex 2') { 1.should == 1 }
        end
        group.stub(:examples_to_run) { group.examples }
        group.run(reporter).should be_true
      end

      it "returns false if any of the examples fail" do
        group = ExampleGroup.describe('group') do
          example('ex 1') { 1.should == 1 }
          example('ex 2') { 1.should == 2 }
        end
        group.stub(:examples_to_run) { group.examples }
        group.run(reporter).should be_false
      end

      it "runs all examples, regardless of any of them failing" do
        group = ExampleGroup.describe('group') do
          example('ex 1') { 1.should == 2 }
          example('ex 2') { 1.should == 1 }
        end
        group.stub(:examples_to_run) { group.examples }
        group.examples_to_run.each do |example|
          example.should_receive(:run)
        end
        group.run(reporter).should be_false
      end
    end

    describe "how instance variables inherit" do
      before(:all) do
        @before_all_top_level = 'before_all_top_level'
      end

      before(:each) do
        @before_each_top_level = 'before_each_top_level'
      end

      it "should be able to access a before each ivar at the same level" do
        @before_each_top_level.should == 'before_each_top_level'
      end

      it "should be able to access a before all ivar at the same level" do
        @before_all_top_level.should == 'before_all_top_level'
      end

      it "should be able to access the before all ivars in the before_all_ivars hash", :ruby => 1.8 do
        running_example.example_group.before_all_ivars.should include('@before_all_top_level' => 'before_all_top_level')
      end

      it "should be able to access the before all ivars in the before_all_ivars hash", :ruby => 1.9 do
        running_example.example_group.before_all_ivars.should include(:@before_all_top_level => 'before_all_top_level')
      end

      describe "but now I am nested" do
        it "should be able to access a parent example groups before each ivar at a nested level" do
          @before_each_top_level.should == 'before_each_top_level'
        end

        it "should be able to access a parent example groups before all ivar at a nested level" do
          @before_all_top_level.should == "before_all_top_level"
        end

        it "changes to before all ivars from within an example do not persist outside the current describe" do
          @before_all_top_level = "ive been changed"
        end

        describe "accessing a before_all ivar that was changed in a parent example_group" do
          it "does not have access to the modified version" do
            @before_all_top_level.should == 'before_all_top_level'
          end
        end
      end

    end

    describe "ivars are not shared across examples" do
      it "(first example)" do
        @a = 1
        @b.should be_nil
      end

      it "(second example)" do
        @b = 2
        @a.should be_nil
      end
    end

    describe "#let" do
      let(:counter) do
        Class.new do
          def initialize
            @count = 0
          end
          def count
            @count += 1
          end
        end.new
      end

      it "generates an instance method" do
        counter.count.should == 1
      end

      it "caches the value" do
        counter.count.should == 1
        counter.count.should == 2
      end
    end

    describe "#let!" do
      let!(:creator) do
        class Creator
          @count = 0
          def self.count
            @count += 1
          end
        end
      end

      it "evaluates the value non-lazily" do
        lambda { Creator.count }.should_not raise_error
      end

      it "does not interfere between tests" do 
        Creator.count.should == 1
      end
    end

    describe "#around" do

      around(:each) do |example|
        SelfObserver.new
        example.run
        SelfObserver.cache.clear
      end

      it "has 1 SelfObserver (1)" do
        SelfObserver.cache.length.should == 1
      end

      it "has 1 SelfObserver (2)" do
        SelfObserver.cache.length.should == 1
      end
    end
  end

end
