Feature: match_array matcher

  The `match_array` matcher provides a way to test arrays against each other
  in a way that disregards differences in the ordering between the actual
  and expected array. For example:

    ```ruby
    expect([1, 2, 3]).to    match_array [2, 3, 1] # pass
    expect([:a, :c, :b]).to match_array [:a, :c]  # fail
    ```

  Scenario: array operator matchers
    Given a file named "array_operator_matchers_spec.rb" with:
      """ruby
      describe do
        example { expect([1, 2, 3]).to match_array [1, 2, 3] }
        example { expect([1, 2, 3]).to match_array [1, 3, 2] }
        example { expect([1, 2, 3]).to match_array [2, 1, 3] }
        example { expect([1, 2, 3]).to match_array [2, 3, 1] }
        example { expect([1, 2, 3]).to match_array [3, 1, 2] }
        example { expect([1, 2, 3]).to match_array [3, 2, 1] }

        # deliberate failures
        example { expect([1, 2, 3]).to match_array [1, 2, 1] }
      end
      """
     When I run `rspec array_operator_matchers_spec.rb`
     Then the output should contain "7 examples, 1 failure"
      And the output should contain:
      """
           Failure/Error: example { expect([1, 2, 3]).to match_array [1, 2, 1] }
             expected collection contained:  [1, 1, 2]
             actual collection contained:    [1, 2, 3]
             the missing elements were:      [1]
             the extra elements were:        [3]
      """

