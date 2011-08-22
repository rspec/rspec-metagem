Feature: exit status

  In order to fail the build when it should, the spec CLI exits with an
  appropriate exit status

  Scenario: exit with 0 when all examples pass
    Given a file named "ok_spec.rb" with:
      """
      describe "ok" do
        it "passes" do
        end
      end
      """
    When I run `rspec ok_spec.rb`
    Then the exit status should be 0
    And the examples should all pass

  Scenario: exit with 1 when one example fails
    Given a file named "ko_spec.rb" with:
      """
      describe "KO" do
        it "fails" do
          raise "KO"
        end
      end
      """
    When I run `rspec ko_spec.rb`
    Then the exit status should be 1
    And the output should contain "1 example, 1 failure"

  Scenario: exit with 1 when a nested examples fails
    Given a file named "nested_ko_spec.rb" with:
      """
      describe "KO" do
        describe "nested" do
          it "fails" do
            raise "KO"
          end
        end
      end
      """
    When I run `rspec nested_ko_spec.rb`
    Then the exit status should be 1
    And the output should contain "1 example, 1 failure"

  Scenario: exit with 0 when no examples are run
    Given a file named "a_no_examples_spec.rb" with:
      """
      """
    When I run `rspec a_no_examples_spec.rb`
    Then the exit status should be 0
    And the output should contain "0 examples"

  Scenario: exit with 1 when an at_exit hook sets the exit code
    Given a file named "exit_at_spec.rb" with:
      """
      require 'rspec/autorun'

      describe "exit_at" do
        it "fails" do
          at_exit { exit 0 }
          1.should == 2
        end
      end
      """
    When I run `rspec exit_at_spec.rb`
    Then the exit status should be 1
    And the output should contain "1 example, 1 failure"
