Feature: pending examples

  RSpec offers a number of different ways to indicate that an example is
  disabled pending some action.

  Scenario: pending any arbitrary reason with a failing example
    Given a file named "pending_without_block_spec.rb" with:
      """ruby
      describe "an example" do
        it "is implemented but waiting" do
          pending("something else getting finished")
          fail
        end
      end
      """
    When I run `rspec pending_without_block_spec.rb`
    Then the exit status should be 0
    And the output should contain "1 example, 0 failures, 1 pending"
    And the output should contain:
      """
      Pending:
        an example is implemented but waiting
          # something else getting finished
          # ./pending_without_block_spec.rb:2
      """
  Scenario: pending any arbitrary reason with a passing example
    Given a file named "pending_with_passing_example_spec.rb" with:
      """ruby
      describe "an example" do
        it "is implemented but waiting" do
          pending("something else getting finished")
          expect(1).to be(1)
        end
      end
      """
    When I run `rspec pending_with_passing_example_spec.rb`
    Then the exit status should not be 0
    And the output should contain "1 example, 1 failure"
    And the output should contain "FIXED"
    And the output should contain "Expected pending 'something else getting finished' to fail. No Error was raised."
    And the output should contain "pending_with_passing_example_spec.rb:2"

  Scenario: pending for an example that is currently passing
    Given a file named "pending_with_passing_block_spec.rb" with:
      """ruby
      describe "an example" do
        pending("something else getting finished") do
          expect(1).to eq(1)
        end
      end
      """
    When I run `rspec pending_with_passing_block_spec.rb`
    Then the exit status should not be 0
    And the output should contain "1 example, 1 failure"
    And the output should contain "FIXED"
    And the output should contain "Expected pending 'No reason given' to fail. No Error was raised."
    And the output should contain "pending_with_passing_block_spec.rb:2"

  Scenario: pending for an example that is currently passing with a reason
    Given a file named "pending_with_passing_block_spec.rb" with:
      """ruby
      describe "an example" do
        example("something else getting finished", :pending => 'unimplemented') do
          expect(1).to eq(1)
        end
      end
      """
    When I run `rspec pending_with_passing_block_spec.rb`
    Then the exit status should not be 0
    And the output should contain "1 example, 1 failure"
    And the output should contain "FIXED"
    And the output should contain "Expected pending 'unimplemented' to fail. No Error was raised."
    And the output should contain "pending_with_passing_block_spec.rb:2"

  Scenario: example with no docstring and pending method using documentation formatter
    Given a file named "pending_with_no_docstring_spec.rb" with:
      """ruby
      describe "an example" do
        it "checks something" do
          expect(1).to eq(1)
        end
        specify do
          pending
          fail
        end
      end
      """
    When I run `rspec pending_with_no_docstring_spec.rb --format documentation`
    Then the exit status should be 0
    And the output should contain "2 examples, 0 failures, 1 pending"
    And the output should contain:
      """
      an example
        checks something
        example at ./pending_with_no_docstring_spec.rb:5 (PENDING: No reason given)
      """

  Scenario: pending with no docstring using documentation formatter
    Given a file named "pending_with_no_docstring_spec.rb" with:
      """ruby
      describe "an example" do
        it "checks something" do
          expect(1).to eq(1)
        end
        pending do
          fail
        end
      end
      """
    When I run `rspec pending_with_no_docstring_spec.rb --format documentation`
    Then the exit status should be 0
    And the output should contain "2 examples, 0 failures, 1 pending"
    And the output should contain:
      """
      an example
        checks something
        example at ./pending_with_no_docstring_spec.rb:5 (PENDING: No reason given)
      """
