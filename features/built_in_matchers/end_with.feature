Feature: end_with matcher

  The end_with matcher is mostly sugar to make your string tests
  read better

    "A test string".should end_with "string"
    "A test string".should_not end_with "Something"

  The test is case sensitive.

  Scenario: string usage
    Given a file named "string_end_with_matcher_spec.rb" with:
      """
      describe "A test string" do
        it { should end_with "string" }
        it { should_not end_with "Something" }

        # deliberate failures
        it { should_not end_with "string" }
        it { should end_with "Something" }
      end
      """
    When I run `rspec string_end_with_matcher_spec.rb`
    Then the output should contain all of these:
      | 4 examples, 2 failures                            |
      | expected "A test string" not to end with "string" |
      | expected "A test string" to end with "Something"  |

  Scenario: array usage
    Given a file named "array_end_with_matcher_spec.rb" with:
      """
      describe [0, 1, 2, 3, 4] do
        it { should end_with 4 }
        it { should end_with [3, 4] }
        it { should_not end_with "Something" }
        it { should_not end_with [0, 1, 2, 3, 4, 5] }

        # deliberate failures
        it { should_not end_with 4 }
        it { should end_with "Something" }
      end
      """
    When I run `rspec array_end_with_matcher_spec.rb`
    Then the output should contain all of these:
      | 6 examples, 2 failures                           |
      | expected [0, 1, 2, 3, 4] not to end with 4       |
      | expected [0, 1, 2, 3, 4] to end with "Something" |
