Feature: Nested example groups

  As an RSpec user
  I want to use alternate names for describe
  So that I can better organize my examples

  Scenario Outline: Using context
    Given a file named "context_instead_of_describe.rb" with:
    """
    require 'rspec/autorun'
    require 'rspec/expectations'
    Rspec::Core::ExampleGroup.send(:include, Rspec::Matchers)

    context "Using context" do
      context "with nested context" do
        it "should do this" do
          true.should be_true
        end
      end
    end
    """
    When I run "<Command> context_instead_of_describe.rb -fs"
    Then the stdout should match /^Using context/
    And the stdout should match /^\s+with nested context/

  Scenarios: Run with ruby and spec
    | Command |
    | ruby    |
    | rspec   |
