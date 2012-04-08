Feature: start_with matcher

  The start_with matcher is mostly sugar to make your string tests
  read better

    "A test string".should start_with "A test"
    "A test string".should_not start_with "Something"

  The test is case sensitive.

  Scenario: basic usage
    Given a file named "start_with_matcher_spec.rb" with:
      """
      describe "A test string" do
        it { should start_with "A test" }
        it { should_not start_with "Something" }

        # deliberate failures
        it { should_not start_with "A test" }
        it { should start_with "Something" }
      end
      """
    When I run `rspec start_with_matcher_spec.rb`
    Then the output should contain all of these:
      | 4 examples, 2 failures                              |
      | expected 'A test string' not to start with 'A test' |
      | expected 'A test string' to start with 'Something   |


