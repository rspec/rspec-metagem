require 'spec_helper'

def describe_double(describes=Object)
  group = Rspec::Core::ExampleGroup.describe(describes) {}
  remove_last_describe_from_world
  yield group if block_given?
  group
end

describe Rspec::Core::ExampleGroupSubject do

  describe "implicit subject" do
    describe "with a class" do
      it "returns an instance of the class" do
        describe_double(Array).subject.call.should == []
      end
    end
    
    describe "with a Module" do
      it "returns the Module" do
        describe_double(Enumerable).subject.call.should == Enumerable
      end
    end
    
    describe "with a string" do
      it "return the string" do
        describe_double("Foo").subject.call.should == 'Foo'
      end
    end

    describe "with a number" do
      it "returns the number" do
        describe_double(15).subject.call.should == 15
      end
    end
    
  end
  
   describe "explicit subject" do
      describe "defined in a top level group" do
        it "replaces the implicit subject in that group" do
          group = describe_double(Array)
          group.subject { [1,2,3] }
          group.subject.call.should == [1,2,3]
        end
      end

      describe "defined in a top level group" do
        before do
          @group = describe_double
          @group.subject{ [4,5,6] }
        end

        it "is available in a nested group (subclass)" do
          nested = @group.describe("I'm nested!") { }
          nested.subject.call.should == [4,5,6]
        end

        it "is available in a doubly nested group (subclass)" do
          nested_group = @group.describe("Nesting level 1") { }
          doubly_nested_group = nested_group.describe("Nesting level 1") { }
          doubly_nested_group.subject.call.should == [4,5,6]
        end
      end
    end
      
end
