Feature: Nested example groups

  As an RSpec user
  I want to nest examples groups
  So that I can better organize my examples

  Scenario: Nested example groups
    Given a file named "nested_example_groups.rb" with:
    """
    describe "Some Object" do
      describe "with some more context" do
        it "should do this" do
          true.should be_true
        end
      end
      describe "with some other context" do
        it "should do that" do
          false.should be_false
        end
      end
    end
    """
    When I run "rspec nested_example_groups.rb -fdoc"
    Then the output should contain "Some Object"
    And  the output should contain "with some more context"
    And  the output should contain "with some other context"

  Scenario: failure in outer group continues to run inner groups
    Given a file named "nested_example_groups.rb" with:
    """
    describe "something" do
      it "fails" do
        raise "failure"
      end

      context "nested" do
        it "passes" do
        end
      end
    end
    """
    When I run "rspec nested_example_groups.rb -fdoc"
    Then the output should contain "2 examples, 1 failure"
    And the output should contain "passes"
