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

  @wip
  Scenario: Defining a helper method for a shared example group
    # Need to decide whether to support super() behaviour
    Given a file named "shared_example_group_with_helper_method_block.rb" with:
    """
    class MyArray < Array; end

    shared_examples_for "a collection object" do
      def instance
        "this default implementation is ignored when it_should_behave_like has a block with a definition " +
        "but it can be accessed using super"
      end

      it "should have 3 items" do
        instance.size.should == 3
      end

      it "should return the first item from #first" do
        instance.first.should == 7
      end

      it "should return the default implementation of #instance from #last" do
        instance.last =~ /default implementation/
      end

      it "should be an instance of the expected class" do
        instance.should be_instance_of(described_class)
      end
    end

    describe Array do
      it_should_behave_like "a collection object" do
        def instance; [7, 2, super]; end
      end
    end

    describe MyArray do
      it_should_behave_like "a collection object" do
        def instance; MyArray.new([7, 2, super]); end
      end
    end
    """
    When I run "rspec ./shared_example_group_with_helper_method_block.rb"
    Then the output should contain "8 examples, 0 failures"

  Scenario: Using the rspec DSL in the block passed to it_should_behave_like
    Given a file named "shared_example_group_with_rspec_dsl_in_block.rb" with:
    """
    shared_examples_for "a convoluted example" do
      it "should return 7 from @foo" do
        @foo.should == 7
      end
    end

    describe "An example using rspec DSL methods" do
      it_should_behave_like "a convoluted example" do
        subject { [4, "1234567", 3] }
        let(:second_element) { subject[1] }
        before(:each) { @foo = second_element.size }
      end
    end
    """
    When I run "rspec ./shared_example_group_with_rspec_dsl_in_block.rb"
    Then the output should contain "1 example, 0 failures"
