Feature: comparison matchers

  RSpec provides a number of matchers that are based on Ruby's built-in
  operators. These can be used for generalized comparison of values. E.g.

    ```ruby
    expect(9).to be > 6
    expect(3).to be <= 3
    expect(1).to be < 6
    ```


  Scenario: numeric operator matchers
    Given a file named "numeric_operator_matchers_spec.rb" with:
      """ruby
      describe do
        example { expect(18).to be < 20 }
        example { expect(18).to be > 15 }
        example { expect(18).to be <= 19 }
        example { expect(18).to be >= 17 }

        # deliberate failures
        example { expect(18).to be < 15 }
        example { expect(18).to be > 20 }
        example { expect(18).to be <= 17 }
        example { expect(18).to be >= 19 }
      end
      """
     When I run `rspec numeric_operator_matchers_spec.rb`
     Then the output should contain "8 examples, 4 failures"
      And the output should contain:
      """
           Failure/Error: example { expect(18).to be < 15 }
             expected: < 15
                  got:   18
      """
      And the output should contain:
      """
           Failure/Error: example { expect(18).to be > 20 }
             expected: > 20
                  got:   18
      """
      And the output should contain:
      """
           Failure/Error: example { expect(18).to be <= 17 }
             expected: <= 17
                  got:    18
      """
      And the output should contain:
      """
           Failure/Error: example { expect(18).to be >= 19 }
             expected: >= 19
                  got:    18
      """

  Scenario: string operator matchers
    Given a file named "string_operator_matchers_spec.rb" with:
      """ruby
      describe do
        example { expect("Strawberry").to be < "Tomato" }
        example { expect("Strawberry").to be > "Apple" }
        example { expect("Strawberry").to be <= "Turnip" }
        example { expect("Strawberry").to be >= "Banana" }

        # deliberate failures
        example { expect("Strawberry").to be < "Cranberry" }
        example { expect("Strawberry").to be > "Zuchini" }
        example { expect("Strawberry").to be <= "Potato" }
        example { expect("Strawberry").to be >= "Tomato" }
      end
      """
     When I run `rspec string_operator_matchers_spec.rb`
     Then the output should contain "8 examples, 4 failures"
      And the output should contain:
      """
           Failure/Error: example { expect("Strawberry").to be < "Cranberry" }
             expected: < "Cranberry"
                  got:   "Strawberry"
      """
      And the output should contain:
      """
           Failure/Error: example { expect("Strawberry").to be > "Zuchini" }
             expected: > "Zuchini"
                  got:   "Strawberry"
      """
      And the output should contain:
      """
           Failure/Error: example { expect("Strawberry").to be <= "Potato" }
             expected: <= "Potato"
                  got:    "Strawberry"
      """
      And the output should contain:
      """
           Failure/Error: example { expect("Strawberry").to be >= "Tomato" }
             expected: >= "Tomato"
                  got:    "Strawberry"
      """
