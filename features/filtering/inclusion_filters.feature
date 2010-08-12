Feature: inclusion filters
  
  Scenario: focus on one example
    Given a file named "spec/sample_spec.rb" with:
      """
      RSpec.configure do |c|
        c.filter_run :focus => true
      end

      describe "something" do
        it "does one thing" do
        end

        it "does another thing", :focus => true do
        end
      end
      """
    When I run "rspec ./spec/sample_spec.rb --format doc"
    Then the output should contain "does another thing"
    And the output should not contain "does one thing"

  Scenario: focus on one group
    Given a file named "spec/sample_spec.rb" with:
      """
      RSpec.configure do |c|
        c.filter_run :focus => true
      end

      describe "group 1", :focus => true do
        it "group 1 example 1" do
        end

        it "group 1 example 2" do
        end
      end

      describe "group 2" do
        it "group 2 example 1" do
        end
      end
      """
    When I run "rspec ./spec/sample_spec.rb --format doc"
    Then the output should contain "group 1 example 1"
    And  the output should contain "group 1 example 2"
    And  the output should not contain "group 2 example 1"

  Scenario: no examples match filter
    Given a file named "spec/sample_spec.rb" with:
      """
      RSpec.configure do |c|
        c.filter_run :focus => true
        c.run_all_when_everything_filtered = true
      end

      describe "group 1" do
        it "group 1 example 1" do
        end

        it "group 1 example 2" do
        end
      end

      describe "group 2" do
        it "group 2 example 1" do
        end
      end
      """
    When I run "rspec ./spec/sample_spec.rb --format doc"
    Then the output should contain "No examples were matched by {:focus=>true}, running all"
    And  the output should contain "group 1 example 1"
    And  the output should contain "group 1 example 2"
    And  the output should contain "group 2 example 1"
    And  the output should contain "3 examples, 0 failures"

