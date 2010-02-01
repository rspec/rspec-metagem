Feature: line number appended to file path

  As an RSpec user
  I want to run one example identified by the 
    line number appended to the filepath
  
  Background:
    Given a file named "example_spec.rb" with:
      """
      describe "a group" do

        it "has a first example" do

        end
        
        it "has a second example" do

        end
        
      end
      """

  @wip
  Scenario: two examples - both examples from the group declaration
    When I run "spec example_spec.rb:1 --format doc"
    Then the stdout should match "2 examples, 0 failures"
    And the stdout should match "has a second example"
    And the stdout should match "has a first example"

  Scenario: two examples - first example on declaration line
    When I run "spec example_spec.rb:3 --format doc"
    Then the stdout should match "1 example, 0 failures"
    And the stdout should match "has a first example"
    But the stdout should not match "has a second example"

  Scenario: two examples - second example on declaration line
    When I run "spec example_spec.rb:7 --format doc"
    Then the stdout should match "1 example, 0 failures"
    And the stdout should match "has a second example"
    But the stdout should not match "has a first example"
