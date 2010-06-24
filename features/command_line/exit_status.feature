Feature: exit status
  In order to fail the build when it should,
  the spec CLI exits with an appropriate exit status

  Scenario: exit with 0 when all examples pass
    Given a file named "ok_spec.rb" with:
      """
      describe "ok" do
        it "passes" do
        end
      end
      """
    When I run "rspec ok_spec.rb"
    Then it should pass with:
      """
      1 example, 0 failures
      """

  Scenario: exit with 1 when one example fails
    Given a file named "ko_spec.rb" with:
      """
      describe "KO" do
        it "fails" do
          raise "KO"
        end
      end
      """
    When I run "rspec ko_spec.rb"
    Then it should fail with:
      """
      1 example, 1 failure
      """

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
    When I run "rspec nested_ko_spec.rb"
    Then it should fail with:
      """
      1 example, 1 failure
      """
      
  Scenario: exit with 0 when no examples are run
    Given a file named "spec/a_no_examples_spec.rb" with:
      """
      """
    And a file named "spec/b_one_example_spec.rb" with:
      """
      describe "something" do
        it "does something" do
        end
      end
      """
          
    When I run "rspec spec"
    Then it should pass with:
      """
      1 example, 0 failures
      """
