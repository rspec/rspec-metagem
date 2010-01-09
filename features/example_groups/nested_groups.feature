Feature: Nested example groups

  As an RSpec user
  I want to nest examples groups
  So that I can better organize my examples

  Scenario Outline: Nested example groups
    Given a file named "nested_example_groups.rb" with:
    """
    require 'rspec/autorun'
    require 'rspec/expectations'
    Rspec::Core::ExampleGroup.send(:include, Rspec::Matchers)

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
    When I run "rspec nested_example_groups.rb -fn"
    Then the stdout should match /^Some Object/
    And the stdout should match /^\s+with some more context/
    And the stdout should match /^\s+with some other context/
