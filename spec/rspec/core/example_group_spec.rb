require 'spec_helper'

describe Rspec::Core::ExampleGroup do

  describe "#describe" do

    it "raises an ArgumentError if no type or description is given" do
      lambda { Rspec::Core::ExampleGroup.describe() {} }.should raise_error(ArgumentError, "No arguments given.  You must a least supply a type or description")
    end

    it "raises an ArgumentError if no block is given" do
      lambda { Rspec::Core::ExampleGroup.describe('foo') }.should raise_error(ArgumentError, "You must supply a block when calling describe")
    end

  end

  describe '#name' do

    it "uses the first parameter as name" do
      disconnect_from_world do
        Rspec::Core::ExampleGroup.describe("my favorite pony") { }.name.should == 'my favorite pony'
      end
    end

    it "accepts a constant as the first parameter" do
      disconnect_from_world do
        Rspec::Core::ExampleGroup.describe(Object) { }.name.should == 'Object'
      end
    end

    it "concats nested names" do
      group = isolated_example_group(Object, 'test')
      group.name.should == 'Object test'

      nested_group_one = group.describe('nested one') { }
      nested_group_one.name.should == 'Object test nested one'

      nested_group_two = nested_group_one.describe('nested two') { }
      nested_group_two.name.should == 'Object test nested one nested two'
    end

  end

  describe '#describes' do

    context "with a constant as the first parameter" do

      it "is that constant" do
        disconnect_from_world do
          Rspec::Core::ExampleGroup.describe(Object) { }.describes.should == Object
        end
      end

    end

    context "with a string as the first parameter" do

      it "is nil" do
        disconnect_from_world do
          Rspec::Core::ExampleGroup.describe("i'm a computer") { }.describes.should be_nil
        end
      end

    end

  end

  describe '#description' do

    it "exposes the second parameter as description" do
      disconnect_from_world do
        Rspec::Core::ExampleGroup.describe(Object, "my desc") { }.description.should == 'my desc'
      end
    end

    it "allows the second parameter to be nil" do
      disconnect_from_world do
        Rspec::Core::ExampleGroup.describe(Object, nil) { }.description.should == ""
      end
    end

  end

  describe '#metadata' do

    it "adds the third parameter to the metadata" do
      disconnect_from_world do
        Rspec::Core::ExampleGroup.describe(Object, nil, 'foo' => 'bar') { }.metadata.should include({ "foo" => 'bar' })
      end
    end

    it "adds the caller to metadata" do
      disconnect_from_world do
        Rspec::Core::ExampleGroup.describe(Object) { }.metadata[:behaviour][:caller].any? {|f|
          f =~ /#{__FILE__}/
        }.should be_true
      end
    end

    it "adds the the file_path to metadata" do
      disconnect_from_world do
        Rspec::Core::ExampleGroup.describe(Object) { }.metadata[:behaviour][:file_path].should == __FILE__
      end
    end

    it "has a reader for file_path" do
      disconnect_from_world do
        Rspec::Core::ExampleGroup.describe(Object) { }.file_path.should == __FILE__
      end
    end

    it "adds the line_number to metadata" do
      disconnect_from_world do
        Rspec::Core::ExampleGroup.describe(Object) { }.metadata[:behaviour][:line_number].should == __LINE__
      end
    end

    it "adds file path and line number metadata for arbitrarily nested describes" do
      Rspec::Core::ExampleGroup.describe(Object) do
        Rspec::Core::ExampleGroup.describe("foo") do
          Rspec::Core::ExampleGroup.describe(Object) { }.metadata[:behaviour][:file_path].should == __FILE__
          Rspec::Core::ExampleGroup.describe(Object) { }.metadata[:behaviour][:line_number].should == __LINE__
        end
      end

      4.times { remove_last_example_group_from_world }
    end

  end

  describe "adding before, after, and around hooks" do

    it "should expose the before each blocks at before_eachs" do
      group = isolated_example_group
      group.before(:each) { 'foo' }
      group.should have(1).before_eachs
    end

    it "should maintain the before each block order" do
      group = isolated_example_group 
      group.before(:each) { 15 }
      group.before(:each) { 'A' }
      group.before(:each) { 33.5 }

      group.before_eachs[0].call.should == 15
      group.before_eachs[1].call.should == 'A'
      group.before_eachs[2].call.should == 33.5
    end

    it "should expose the before all blocks at before_alls" do
      group = isolated_example_group
      group.before(:all) { 'foo' }
      group.should have(1).before_alls
    end

    it "should maintain the before all block order" do
      group = isolated_example_group 
      group.before(:all) { 15 }
      group.before(:all) { 'A' }
      group.before(:all) { 33.5 }

      group.before_alls[0].call.should == 15
      group.before_alls[1].call.should == 'A'
      group.before_alls[2].call.should == 33.5
    end

    it "should expose the after each blocks at after_eachs" do
      group = isolated_example_group
      group.after(:each) { 'foo' }
      group.should have(1).after_eachs
    end

    it "should maintain the after each block order" do
      group = isolated_example_group 
      group.after(:each) { 15 }
      group.after(:each) { 'A' }
      group.after(:each) { 33.5 }

      group.after_eachs[0].call.should == 15
      group.after_eachs[1].call.should == 'A'
      group.after_eachs[2].call.should == 33.5
    end

    it "should expose the after all blocks at after_alls" do
      group = isolated_example_group
      group.after(:all) { 'foo' }
      group.should have(1).after_alls
    end

    it "should maintain the after each block order" do
      group = isolated_example_group 
      group.after(:all) { 15 }
      group.after(:all) { 'A' }
      group.after(:all) { 33.5 }

      group.after_alls[0].call.should == 15
      group.after_alls[1].call.should == 'A'
      group.after_alls[2].call.should == 33.5
    end

    it "should expose the around each blocks at after_alls" do
      group = isolated_example_group
      group.around(:each) { 'foo' }
      group.should have(1).around_eachs
    end
    
  end

  describe "adding examples" do

    it "should allow adding an example using 'it'" do
      group = isolated_example_group
      group.it("should do something") { }
      group.examples.size.should == 1
    end

    it "should expose all examples at examples" do
      group = isolated_example_group
      group.it("should do something 1") { }
      group.it("should do something 2") { }
      group.it("should do something 3") { }
      group.examples.size.should == 3
    end

    it "should maintain the example order" do
      group = isolated_example_group
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
        running_example.behaviour.describes.should == Object
      end

      it "sets the description to 'A sample nested describe'" do
        running_example.behaviour.description.should == 'A sample nested group'
      end

      it "has top level metadata from the behaviour and its ancestors" do
        running_example.behaviour.metadata.should include(:little_less_nested => 'yep', :nested_describe => 'yep')
      end

      it "exposes the parent metadata to the contained examples" do
        running_example.metadata.should include(:little_less_nested => 'yep', :nested_describe => 'yep')
      end
    end

  end

  describe "#run_examples" do
    before do
      @fake_formatter = Rspec::Core::Formatters::BaseFormatter.new
    end

    def stub_behaviour
      stub('behaviour', 
        :metadata => Rspec::Core::Metadata.new.process(
          'behaviour_name',
          :caller => ['foo_spec.rb:37']
        )
      ).as_null_object 
    end

    it "should return true if all examples pass" do
      use_formatter(@fake_formatter) do
        passing_example1 = Rspec::Core::Example.new(stub_behaviour, 'description', {}, (lambda { 1.should == 1 }))
        passing_example2 = Rspec::Core::Example.new(stub_behaviour, 'description', {}, (lambda { 1.should == 1 }))
        Rspec::Core::ExampleGroup.stub!(:examples_to_run).and_return([passing_example1, passing_example2])

        Rspec::Core::ExampleGroup.run_examples(stub_behaviour, mock('reporter').as_null_object).should be_true
      end
    end

    it "should return false if any of the examples return false" do
      use_formatter(@fake_formatter) do
        failing_example = Rspec::Core::Example.new(stub_behaviour, 'description', {}, (lambda { 1.should == 2 }))
        passing_example = Rspec::Core::Example.new(stub_behaviour, 'description', {}, (lambda { 1.should == 1 }))
        Rspec::Core::ExampleGroup.stub!(:examples_to_run).and_return([failing_example, passing_example])

        Rspec::Core::ExampleGroup.run_examples(stub_behaviour, mock('reporter').as_null_object).should be_false
      end
    end

    it "should run all examples, regardless of any of them failing" do
      use_formatter(@fake_formatter) do
        failing_example = Rspec::Core::Example.new(stub_behaviour, 'description', {}, (lambda { 1.should == 2 }))
        passing_example = Rspec::Core::Example.new(stub_behaviour, 'description', {}, (lambda { 1.should == 1 }))
        Rspec::Core::ExampleGroup.stub!(:examples_to_run).and_return([failing_example, passing_example])

        passing_example.should_receive(:run)

        Rspec::Core::ExampleGroup.run_examples(stub_behaviour, mock('reporter', :null_object => true))
      end
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

    it "should be able to access the before all ivars in the before_all_ivars hash" do
      with_ruby('1.8') do
        running_example.behaviour.before_all_ivars.should include('@before_all_top_level' => 'before_all_top_level')
      end
      with_ruby('1.9') do
        running_example.behaviour.before_all_ivars.should include(:@before_all_top_level => 'before_all_top_level')
      end
    end

    describe "but now I am nested" do
      it "should be able to access a parent behaviours before each ivar at a nested level" do
        @before_each_top_level.should == 'before_each_top_level'
      end

      it "should be able to access a parent behaviours before all ivar at a nested level" do
        @before_all_top_level.should == "before_all_top_level"
      end

      it "changes to before all ivars from within an example do not persist outside the current describe" do
        @before_all_top_level = "ive been changed"
      end

      describe "accessing a before_all ivar that was changed in a parent behaviour" do
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

  describe "#around" do
    class Thing
      def self.cache
        @cache ||= []
      end

      def initialize
        self.class.cache << self
      end
    end

    around(:each) do |example|
      Thing.new
      example.run
      Thing.cache.clear
    end

    it "has 1 Thing (1)" do
      Thing.cache.length.should == 1
    end

    it "has 1 Thing (2)" do
      Thing.cache.length.should == 1
    end
  end
end
