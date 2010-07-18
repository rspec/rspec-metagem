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

      context "initialized with 3 items" do
        it "has three items" do
          @instance.size.should == 3
        end
      end

      describe "#first" do
        it "returns the first item" do
          @instance.first.should == 7
        end
      end
    end

    describe Array do
      it_should_behave_like "a collection object"
    end

    describe Set do
      it_should_behave_like "a collection object"
    end
    """
    When I run "rspec shared_example_group_spec.rb --format documentation"
    Then the output should contain "4 examples, 0 failures"
    And the output should contain:
      """
      Array
        it should behave like a collection object
          initialized with 3 items
            has three items
          #first
            returns the first item

      Set
        it should behave like a collection object
          initialized with 3 items
            has three items
          #first
            returns the first item
      """

  Scenario: Using a shared example group with a block
    Given a file named "shared_example_group_spec.rb" with:
    """
    require "set"

    shared_examples_for "a collection object" do
      describe "<<" do
        it "adds objects to the end of the collection" do
          collection << 1
          collection << 2
          collection.to_a.should eq([1,2])
        end
      end
    end

    describe Array do
      it_should_behave_like "a collection object" do
        let(:collection) { Array.new }
      end
    end

    describe Set do
      it_should_behave_like "a collection object" do
        let(:collection) { Set.new }
      end
    end
    """
    When I run "rspec shared_example_group_spec.rb --format documentation"
    Then the output should contain "2 examples, 0 failures"
    And the output should contain:
      """
      Array
        it should behave like a collection object
          <<
            adds objects to the end of the collection

      Set
        it should behave like a collection object
          <<
            adds objects to the end of the collection
      """

  Scenario: Aliasing "it_should_behave_like" to "it_has_behavior"
    Given a file named "shared_example_group_spec.rb" with:
      """
      RSpec.configure do |c|
        c.alias_it_should_behave_like_to :it_has_behavior, 'has behavior:'
      end

      shared_examples_for 'sortability' do
        it 'responds to <==>' do
          sortable.should respond_to(:<=>)
        end
      end

      describe String do
        it_has_behavior 'sortability' do
          let(:sortable) { 'sample string' }
        end
      end
      """
    When I run "rspec shared_example_group_spec.rb --format documentation"
    Then the output should contain "1 example, 0 failures"
    And the output should contain:
      """
      String
        has behavior: sortability
          responds to <==>
      """
