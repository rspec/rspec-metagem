require 'spec_helper'

class Bar; end
class Foo; end

module RSpec::Core

  describe World do

    before do
      @world = RSpec.world
    end

    describe "example_groups" do

      it "should contain all defined example groups" do
        group = RSpec::Core::ExampleGroup.describe("group") {}
        @world.example_groups.should include(group)
      end

    end

    describe "applying inclusion filters" do

      before(:each) do
        options_1 = { :foo => 1, :color => 'blue', :feature => 'reporting' }
        options_2 = { :pending => true, :feature => 'reporting'  }
        options_3 = { :array => [1,2,3,4], :color => 'blue' }
        @group1 = RSpec::Core::ExampleGroup.describe(Bar, "find group-1", options_1) { }
        @group2 = RSpec::Core::ExampleGroup.describe(Bar, "find group-2", options_2) { }
        @group3 = RSpec::Core::ExampleGroup.describe(Bar, "find group-3", options_3) { }
        @group4 = RSpec::Core::ExampleGroup.describe(Foo, "find these examples") do
          it('I have no options') {}
          it("this is awesome", :awesome => true) {}
          it("this is too", :awesome => true) {}
          it("not so awesome", :awesome => false) {}
          it("I also have no options") {}
        end
        @example_groups = [@group1, @group2, @group3, @group4]
      end

      it "finds no groups when given no search parameters" do
        @world.apply_inclusion_filters([]).should == []
      end

      it "finds matching groups when filtering on :describes (described class or module)" do
        @world.apply_inclusion_filters(@example_groups, :example_group => { :describes => Bar }).should == [@group1, @group2, @group3]
      end

      it "finds matching groups when filtering on :description with text" do
        @world.apply_inclusion_filters(@example_groups, :example_group => { :description => 'Bar find group-1' }).should == [@group1]
      end

      it "finds matching groups when filtering on :description with a lambda" do
        @world.apply_inclusion_filters(@example_groups, :example_group => { :description => lambda { |v| v.include?('-1') || v.include?('-3') } }).should == [@group1, @group3]
      end

      it "finds matching groups when filtering on :description with a regular expression" do
        @world.apply_inclusion_filters(@example_groups, :example_group => { :description => /find group/ }).should == [@group1, @group2, @group3]
      end

      it "finds one group when searching for :pending => true" do
        @world.apply_inclusion_filters(@example_groups, :pending => true ).should == [@group2]
      end

      it "finds matching groups when filtering on arbitrary metadata with a number" do
        @world.apply_inclusion_filters(@example_groups, :foo => 1 ).should == [@group1]
      end

      it "finds matching groups when filtering on arbitrary metadata with an array" do
        @world.apply_inclusion_filters(@example_groups, :array => [1,2,3,4]).should == [@group3]
      end

      it "finds no groups when filtering on arbitrary metadata with an array but the arrays do not match" do
        @world.apply_inclusion_filters(@example_groups, :array => [4,3,2,1]).should be_empty
      end

      it "finds matching examples when filtering on arbitrary metadata" do
        @world.apply_inclusion_filters(@group4.examples, :awesome => true).should == [@group4.examples[1], @group4.examples[2]]
      end

    end

    describe "applying exclusion filters" do

      it "finds nothing if all describes match the exclusion filter" do
        options = { :network_access => true }

        group1 = ExampleGroup.describe(Bar, "find group-1", options) do
          it("foo") {}
          it("bar") {}
        end

        @world.apply_exclusion_filters(group1.examples, :network_access => true).should == []

        group2 = ExampleGroup.describe(Bar, "find group-1") do
          it("foo", :network_access => true) {}
          it("bar") {}
        end

        @world.apply_exclusion_filters(group2.examples, :network_access => true).should == [group2.examples.last]

      end

      it "finds nothing if a regexp matches the exclusion filter" do
        group = ExampleGroup.describe(Bar, "find group-1", :name => "exclude me with a regex", :another => "foo") do
          it("foo") {}
          it("bar") {}
        end
        @world.apply_exclusion_filters(group.examples, :name => /exclude/).should == []
        @world.apply_exclusion_filters(group.examples, :name => /exclude/, :another => "foo").should == []
        @world.apply_exclusion_filters(group.examples, :name => /exclude/, :another => "foo", :example_group => {
          :describes => lambda { |b| b == Bar } } ).should == []

        @world.apply_exclusion_filters(group.examples, :name => /exclude not/).should == group.examples
        @world.apply_exclusion_filters(group.examples, :name => /exclude/, "another_condition" => "foo").should == group.examples
        @world.apply_exclusion_filters(group.examples, :name => /exclude/, "another_condition" => "foo1").should == group.examples
      end
    end


    describe "preceding_declaration_line" do
      before(:each) do
        @group1_line = 10
        @group2_line = 20
        @group2_example1_line = 30
        @group2_example2_line = 40

        @group1 = RSpec::Core::ExampleGroup.describe(Bar, "group-1") { }
        @group2 = RSpec::Core::ExampleGroup.describe(Bar, "group-2") do
          it('example 1') {}
          it("example 2") {}
        end
        @group1.metadata[:example_group][:line_number] = @group1_line
        @group2.metadata[:example_group][:line_number] = @group2_line
        @group2.examples[0].metadata[:line_number] = @group2_example1_line
        @group2.examples[1].metadata[:line_number] = @group2_example2_line
      end

      it "returns nil if no example or group precedes the line" do
        @world.preceding_declaration_line(@group1_line-1).should == nil
      end

      it "returns the argument line number if a group starts on that line" do
        @world.preceding_declaration_line(@group1_line).should == @group1_line
      end

      it "returns the argument line number if an example starts on that line" do
        @world.preceding_declaration_line(@group2_example1_line).should == @group2_example1_line
      end

      it "returns line number of a group that immediately precedes the argument line" do
        @world.preceding_declaration_line(@group2_line+1).should == @group2_line
      end

      it "returns line number of an example that immediately precedes the argument line" do
        @world.preceding_declaration_line(@group2_example1_line+1).should == @group2_example1_line
      end

    end
  end

end
