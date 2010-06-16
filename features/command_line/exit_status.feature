Feature: exit status
  In order to fail the build when it should,
  the spec CLI should exit with an appropriate
  exit status

  Background:
    Given a file named "ok_spec.rb" with:
      """
      describe "ok" do
        it "passes" do
        end
      end
      """
    Given a file named "ko_spec.rb" with:
      """
      describe "KO" do
        it "fails" do
          raise "KO"
        end
      end
      """
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

  Scenario: exit with 0 when all pass
    When I run "ruby -rubygems ../../bin/rspec ok_spec.rb"
    Then it should pass with:
      """
      1 example, 0 failures
      """

  Scenario: exit with 1 when one fails
    When I run "ruby -rubygems ../../bin/rspec ko_spec.rb"
    Then it should fail with:
      """
      1 example, 1 failure
      """

    Scenario: exit with 1 when one fails in a nested one
      When I run "ruby -rubygems ../../bin/rspec nested_ko_spec.rb"
      Then it should fail with:
        """
        1 example, 1 failure
        """
