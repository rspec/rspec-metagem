Feature: match matcher

  The match matcher calls `#match` on the object, passing if `#match` returns a
  truthy (not `false` or `nil`) value.  Regexp and String both provide a `#match`
  method.

    ```ruby
    expect("a string").to match(/str/) # passes
    expect("a string").to match(/foo/) # fails
    expect(/foo/).to match("food")     # passes
    expect(/foo/).to match("drinks")   # fails
    ```

  You can also use this matcher to match nested data structures when
  composing matchers.

  Scenario: string usage
    Given a file named "string_match_spec.rb" with:
      """ruby
      describe "a string" do
        it { should match(/str/) }
        it { should_not match(/foo/) }

        # deliberate failures
        it { should_not match(/str/) }
        it { should match(/foo/) }
      end
      """
    When I run `rspec string_match_spec.rb`
    Then the output should contain all of these:
      | 4 examples, 2 failures                 |
      | expected "a string" not to match /str/ |
      | expected "a string" to match /foo/     |

  Scenario: regular expression usage
    Given a file named "regexp_match_spec.rb" with:
      """ruby
      describe /foo/ do
        it { should match("food") }
        it { should_not match("drinks") }

        # deliberate failures
        it { should_not match("food") }
        it { should match("drinks") }
      end
      """
    When I run `rspec regexp_match_spec.rb`
    Then the output should contain all of these:
      | 4 examples, 2 failures             |
      | expected /foo/ not to match "food" |
      | expected /foo/ to match "drinks"   |
