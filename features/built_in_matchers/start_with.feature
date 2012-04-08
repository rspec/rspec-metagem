Feature: start_with matcher

  The start_with matcher is mostly sugar to make your string tests
  read better

    "A test string".should start_with "A test"
    "A test string".should_not start_with "Something"

  The test is case sensitive.

  Scenario: string usage
    Given a file named "string_start_with_matcher_spec.rb" with:
      """
      describe "A test string" do
        it { should start_with "A test" }
        it { should_not start_with "Something" }

        # deliberate failures
        it { should_not start_with "A test" }
        it { should start_with "Something" }
      end
      """
    When I run `rspec string_start_with_matcher_spec.rb`
    Then the output should contain all of these:
      | 4 examples, 2 failures                              |
      | expected "A test string" not to start with "A test" |
      | expected "A test string" to start with "Something"  |

  Scenario: array usage
    Given a file named "array_start_with_matcher_spec.rb" with:
      """
      describe [0, 1, 2, 3, 4] do
        it { should start_with 0 }
        it { should start_with [0, 1] }
        it { should_not start_with "Something" }
        it { should_not start_with [0, 1, 2, 3, 4, 5] }

        # deliberate failures
        it { should_not start_with 0 }
        it { should start_with "Something" }
      end
      """
    When I run `rspec array_start_with_matcher_spec.rb`
    Then the output should contain all of these:
      | 6 examples, 2 failures                             |
      | expected [0, 1, 2, 3, 4] not to start with 0       |
      | expected [0, 1, 2, 3, 4] to start with "Something" |

