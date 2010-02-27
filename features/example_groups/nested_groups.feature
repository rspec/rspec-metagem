Feature: Nested example groups

  As an RSpec user
  I want to nest examples groups
  So that I can better organize my examples

  @wip
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
    Then I should see /^Some Object/
    And I should see /^\s+with some more context/
    And I should see /^\s+with some other context/
