Feature: line number appended to file path

  As an RSpec user
  I want to run one example identified by the 
    line number appended to the filepath
  
  Background:
    Given a file named "example_spec.rb" with:
      """
      describe "outer group" do

        it "first example in outer group" do

        end
        
        it "second example in outer group" do

        end

        describe "nested group" do
          
          it "example in nested group" do

          end
        
        end

      end
      """

@wip
  Scenario: nested groups - outer group on declaration line
    When I run "rspec example_spec.rb:1 --format doc"
    Then I should see "3 examples, 0 failures"
    And I should see "second example in outer group"
    And I should see "first example in outer group"
    And I should see "example in nested group"

  Scenario: nested groups - inner group on declaration line
    When I run "rspec example_spec.rb:11 --format doc"
    Then I should see "1 example, 0 failures"
    And I should see "example in nested group"
    And I should not see "second example in outer group"
    And I should not see "first example in outer group"

  Scenario: two examples - first example on declaration line
    When I run "rspec example_spec.rb:3 --format doc"
    Then I should see "1 example, 0 failures"
    And I should see "first example in outer group"
    But I should not see "second example in outer group"
    And I should not see "example in nested group"

  Scenario: two examples - second example on declaration line
    When I run "rspec example_spec.rb:7 --format doc"
    Then I should see "1 example, 0 failures"
    And I should see "second example in outer group"
    But I should not see "first example in outer group"
    And I should not see "example in nested group"
