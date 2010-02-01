require 'spec_helper'

class Bar; end
class Foo; end

describe Rspec::Core::World do
  
  before do
    @world = Rspec::Core::World.new
    Rspec::Core.stub!(:world).and_return(@world)
  end

  describe "behaviour groups" do
  
    it "should contain all defined behaviour groups" do
      behaviour_group = Rspec::Core::ExampleGroup.describe(Bar, 'Empty Behaviour Group') { }
      @world.behaviours.should include(behaviour_group)       
    end
  
  end
  
  describe "applying inclusion filters" do
  
    before(:all) do
      options_1 = { :foo => 1, :color => 'blue', :feature => 'reporting' }
      options_2 = { :pending => true, :feature => 'reporting'  }
      options_3 = { :array => [1,2,3,4], :color => 'blue' }      
      @bg1 = Rspec::Core::ExampleGroup.describe(Bar, "find group-1", options_1) { }
      @bg2 = Rspec::Core::ExampleGroup.describe(Bar, "find group-2", options_2) { }
      @bg3 = Rspec::Core::ExampleGroup.describe(Bar, "find group-3", options_3) { }
      @bg4 = Rspec::Core::ExampleGroup.describe(Foo, "find these examples") do
        it('I have no options') {}
        it("this is awesome", :awesome => true) {}
        it("this is too", :awesome => true) {}
        it("not so awesome", :awesome => false) {}
        it("I also have no options") {}
      end
      @behaviours = [@bg1, @bg2, @bg3, @bg4]
    end
    
    after(:all) do
      Rspec::Core.world.behaviours.delete(@bg1)
      Rspec::Core.world.behaviours.delete(@bg2)
      Rspec::Core.world.behaviours.delete(@bg3)
      Rspec::Core.world.behaviours.delete(@bg4)
    end
  
    it "finds no groups when given no search parameters" do
      @world.apply_inclusion_filters([]).should == []
    end
  
    it "finds matching groups when filtering on :describes (described class or module)" do
      @world.apply_inclusion_filters(@behaviours, :behaviour => { :describes => Bar }).should == [@bg1, @bg2, @bg3]
    end
    
    it "finds matching groups when filtering on :description with text" do
      @world.apply_inclusion_filters(@behaviours, :behaviour => { :description => 'find group-1' }).should == [@bg1]
    end
    
    it "finds matching groups when filtering on :description with a lambda" do
      @world.apply_inclusion_filters(@behaviours, :behaviour => { :description => lambda { |v| v.include?('-1') || v.include?('-3') } }).should == [@bg1, @bg3]
    end
    
    it "finds matching groups when filtering on :description with a regular expression" do
      @world.apply_inclusion_filters(@behaviours, :behaviour => { :description => /find group/ }).should == [@bg1, @bg2, @bg3]
    end
    
    it "finds one group when searching for :pending => true" do
      @world.apply_inclusion_filters(@behaviours, :pending => true ).should == [@bg2]
    end
  
    it "finds matching groups when filtering on arbitrary metadata with a number" do
      @world.apply_inclusion_filters(@behaviours, :foo => 1 ).should == [@bg1]
    end
    
    it "finds matching groups when filtering on arbitrary metadata with an array" do
      @world.apply_inclusion_filters(@behaviours, :array => [1,2,3,4]).should == [@bg3]
    end
  
    it "finds no groups when filtering on arbitrary metadata with an array but the arrays do not match" do
      @world.apply_inclusion_filters(@behaviours, :array => [4,3,2,1]).should be_empty
    end    
  
    it "finds matching examples when filtering on arbitrary metadata" do
      @world.apply_inclusion_filters(@bg4.examples, :awesome => true).should == [@bg4.examples[1], @bg4.examples[2]]
    end
    
  end
  
  describe "applying exclusion filters" do
    
    it "should find nothing if all describes match the exclusion filter" do
      options = { :network_access => true }      
      
      isolate_example_group do
        group1 = Rspec::Core::ExampleGroup.describe(Bar, "find group-1", options) do
          it("foo") {}
          it("bar") {}
        end
        
        @world.apply_exclusion_filters(group1.examples, :network_access => true).should == []
      end
      
      isolate_example_group do
        group2 = Rspec::Core::ExampleGroup.describe(Bar, "find group-1") do
          it("foo", :network_access => true) {}
          it("bar") {}
        end
        
        @world.apply_exclusion_filters(group2.examples, :network_access => true).should == [group2.examples.last]
      end
  
    end
    
    it "should find nothing if a regexp matches the exclusion filter" do
      isolate_example_group do
        group = Rspec::Core::ExampleGroup.describe(Bar, "find group-1", :name => "exclude me with a regex", :another => "foo") do
          it("foo") {}
          it("bar") {}
        end
        @world.apply_exclusion_filters(group.examples, :name => /exclude/).should == []
        @world.apply_exclusion_filters(group.examples, :name => /exclude/, :another => "foo").should == []
        @world.apply_exclusion_filters(group.examples, :name => /exclude/, :another => "foo", :behaviour => {
          :describes => lambda { |b| b == Bar } } ).should == []
        
        @world.apply_exclusion_filters(group.examples, :name => /exclude not/).should == group.examples
        @world.apply_exclusion_filters(group.examples, :name => /exclude/, "another_condition" => "foo").should == group.examples
        @world.apply_exclusion_filters(group.examples, :name => /exclude/, "another_condition" => "foo1").should == group.examples
      end
    end
    
  end
  
  describe "filtering behaviours" do
    
    before(:all) do
      @group1 = Rspec::Core::ExampleGroup.describe(Bar, "find these examples") do
        it('I have no options',       :color => :red, :awesome => true) {}
        it("I also have no options",  :color => :red, :awesome => true) {}
        it("not so awesome",          :color => :red, :awesome => false) {}
      end
    end
    
    after(:all) do
      Rspec::Core.world.behaviours.delete(@group1)
    end

    it "should run matches" do
      Rspec::Core.world.stub!(:exclusion_filter).and_return({ :awesome => false })
      Rspec::Core.world.stub!(:filter).and_return({ :color => :red })
      Rspec::Core.world.stub!(:behaviours).and_return([@group1])
      filtered_behaviours = @world.filter_behaviours
      filtered_behaviours.should == [@group1]
      @group1.examples_to_run.should == @group1.examples[0..1]      
    end
    
  end

end
