Feature: pending examples

  RSpec offers three ways to indicate that an example is disabled pending
  some action.

  Scenario: pending implementation
    Given a file named "example_without_block_spec.rb" with:
      """
      describe "an example" do
        it "is a pending example"
      end
      """
    When I run "rspec example_without_block_spec.rb"
    Then the exit status should be 0
    And I should see "1 example, 0 failures, 1 pending"
    And I should see "Not Yet Implemented"
    And I should see "example_without_block_spec.rb:2"

  Scenario: pending any arbitary reason, with no block
    Given a file named "pending_without_block_spec.rb" with:
      """
      describe "an example" do
        it "is implemented but waiting" do
          pending("something else getting finished")
          this_should_not_get_executed
        end
      end
      """
    When I run "rspec pending_without_block_spec.rb"
    Then the exit status should be 0
    And I should see "1 example, 0 failures, 1 pending"
    And I should see "(something else getting finished)"
    And I should see "pending_without_block_spec.rb:2"

  Scenario: pending any arbitary reason, with a block that fails
    Given a file named "pending_with_failing_block_spec.rb" with:
      """
      describe "an example" do
        it "is implemented but waiting" do
          pending("something else getting finished") do
            raise "this is the failure"
          end
        end
      end
      """
    When I run "rspec pending_with_failing_block_spec.rb"
    Then the exit status should be 0
    And I should see "1 example, 0 failures, 1 pending"
    And I should see "(something else getting finished)"
    And I should see "pending_with_failing_block_spec.rb:2"

  Scenario: pending any arbitary reason, with a block that passes
    Given a file named "pending_with_passing_block_spec.rb" with:
      """
      describe "an example" do
        it "is implemented but waiting" do
          pending("something else getting finished") do
            true.should be(true)
          end
        end
      end
      """
    When I run "rspec pending_with_passing_block_spec.rb"
    Then the exit status should not be 0
    And I should see "1 example, 1 failure"
    And I should see "FIXED"
    And I should see "Expected pending 'something else getting finished' to fail. No Error was raised."
    And I should see "pending_with_passing_block_spec.rb:3"
