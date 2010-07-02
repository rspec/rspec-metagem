Feature: Nested example groups

  As an RSpec user
  I want to use alternate names for describe
  So that I can better organize my examples

  Scenario: Using context
    Given a file named "context_instead_of_describe_spec.rb" with:
    """
    require "rspec/expectations"

    describe "Using context" do
      context "with nested context" do
        it "should do this" do
          true.should be_true
        end
      end
    end
    """
    When I run "rspec ./context_instead_of_describe_spec.rb -fn"
    Then the output should contain:
      """
      Using context
        with nested context
      """
