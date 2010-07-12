Feature: Shared example group

  As an RSpec user
  I want to share my examples
  In order to reduce duplication in my specs

  Scenario: Using a shared example group
    Given a file named "shared_example_group_spec.rb" with:
    """
    require "set"

    shared_examples_for "a collection object" do
      before(:each) do
        @instance = described_class.new([7, 2, 4])
      end

      it "should have 3 items" do
        @instance.size.should == 3
      end

      it "should return the first item from #first" do
        @instance.first.should == 7
      end
    end

    describe Array do
      it_should_behave_like "a collection object"
    end

    describe Set do
      it_should_behave_like "a collection object"
    end
    """
    When I run "rspec ./shared_example_group_spec.rb"
    Then the output should contain "4 examples, 0 failures"
