Feature: end_with matcher

  The end_with matcher is mostly sugar to make your string tests
  read better

    "A test string".should end_with "string"
    "A test string".should_not end_with "Something"

  The test is case sensitive.

  Scenario: basic usage
    Given a file named "end_with_matcher_spec.rb" with:
      """
      describe "A test string" do
        it { should end_with "string" }
        it { should_not end_with "Something" }

        # deliberate failures
        it { should_not end_with "string" }
        it { should end_with "Something" }
      end
      """
    When I run `rspec end_with_matcher_spec.rb`
    Then the output should contain all of these:
      | 4 examples, 2 failures                              |
      | expected 'A test string' not to end with 'string' |
      | expected 'A test string' to end with 'Something   |