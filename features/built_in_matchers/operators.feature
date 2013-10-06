Feature: operator matchers

  RSpec provides a number of matchers that are based on Ruby's built-in
  operators. These pretty much work like you expect except that they require
  the `be` matcher when using the `expect` syntax. For example, each of these
  pass:

    ```ruby
    expect(7).to be == 7
    expect([1, 2, 3]).to be == [1, 2, 3]
    expect("this is a string").to be =~ /^this/
    expect("this is a string").not_to be =~ /^that/
    expect(String).to be === "this is a string"
    ```

  You can also use comparison operators without the "be" matcher when using
  the `should` syntax:

    ```ruby
    7.should == 7
    [1, 2, 3].should == [1, 2, 3]
    "this is a string".should =~ /^this/
    "this is a string".should_not =~ /^that/
    String.should === "this is a string"
    ```

  RSpec also provides a `=~` matcher for arrays that disregards differences in
  the ordering between the actual and expected array.  For example:

    ```ruby
    expect([1, 2, 3]).to =~ [2, 3, 1] # pass
    expect([:a, :c, :b]).to =~ [:a, :c] # fail
    ```
  However, we recommend the use of `match_array` instead:

    ```ruby
    expect([1, 2, 3]).to match_array [2, 3, 1] # pass
    expect([:a, :c, :b]).to match_array [:a, :c] # fail
    ```
  Scenario: numeric operator matchers
    Given a file named "numeric_operator_matchers_spec.rb" with:
      """ruby
      describe do
        example { expect(18).to be == 18 }
        example { expect(18).to be < 20 }
        example { expect(18).to be > 15 }
        example { expect(18).to be <= 19 }
        example { expect(18).to be >= 17 }

        example { expect(18).to_not be == 28 }

        # deliberate failures
        example { expect(18).to be == 28 }
        example { expect(18).to be < 15 }
        example { expect(18).to be > 20 }
        example { expect(18).to be <= 17 }
        example { expect(18).to be >= 19 }

      end
      """
     When I run `rspec numeric_operator_matchers_spec.rb`
     Then the output should contain "11 examples, 5 failures"
      And the output should contain:
      """
           Failure/Error: example { expect(18).to be == 28 }
             expected: == 28
                  got:    18
      """
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
        example { expect("Strawberry").to be == "Strawberry" }
        example { expect("Strawberry").to be < "Tomato" }
        example { expect("Strawberry").to be > "Apple" }
        example { expect("Strawberry").to be <= "Turnip" }
        example { expect("Strawberry").to be >= "Banana" }
        example { expect("Strawberry").to be =~ /berry/ }

        example { expect("Strawberry").to_not be == "Peach" }
        example { expect("Strawberry").to_not be =~ /apple/ }

        it "reports that it is a string using ===" do
          expect(String).to be === subject
        end

        # deliberate failures
        example { expect("Strawberry").to be == "Peach" }
        example { expect("Strawberry").to be < "Cranberry" }
        example { expect("Strawberry").to be > "Zuchini" }
        example { expect("Strawberry").to be <= "Potato" }
        example { expect("Strawberry").to be >= "Tomato" }
        example { expect("Strawberry").to be =~ /apple/ }

        example { expect("Strawberry").to_not be =~ /berry/ }

        it "fails a spec asserting that it is a symbol" do
          expect(Symbol).to be === "Strawberry"
        end
      end
      """
     When I run `rspec string_operator_matchers_spec.rb`
     Then the output should contain "17 examples, 8 failures"
      And the output should contain:
      """
           Failure/Error: example { expect("Strawberry").to be == "Peach" }
             expected: == "Peach"
                  got:    "Strawberry"
      """
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
      And the output should contain:
      """
           Failure/Error: example { expect("Strawberry").to be =~ /apple/ }
             expected: =~ /apple/
                  got:    "Strawberry"
      """
      And the output should contain:
      """
           Failure/Error: example { expect("Strawberry").to_not be =~ /berry/ }
      """
      And the output should contain:
      """
           Failure/Error: expect(Symbol).to be === "Strawberry"
             expected: === "Strawberry"
                  got:     Symbol
      """

  Scenario: array operator matchers
    Given a file named "array_operator_matchers_spec.rb" with:
      """ruby
      describe [1, 2, 3] do
        it { should == [1, 2, 3] }
        it { should_not == [1, 3, 2] }

        it { should match_array [1, 2, 3] }
        it { should match_array [1, 3, 2] }
        it { should match_array [2, 1, 3] }
        it { should match_array [2, 3, 1] }
        it { should match_array [3, 1, 2] }
        it { should match_array [3, 2, 1] }

        # deliberate failures
        it { should_not == [1, 2, 3] }
        it { should == [1, 3, 2] }
        it { should match_array [1, 2, 1] }
      end
      """
     When I run `rspec array_operator_matchers_spec.rb`
     Then the output should contain "11 examples, 3 failures"
      And the output should contain:
      """
           Failure/Error: it { should_not == [1, 2, 3] }
             expected not: == [1, 2, 3]
                      got:    [1, 2, 3]
      """
      And the output should contain:
      """
           Failure/Error: it { should == [1, 3, 2] }
             expected: [1, 3, 2]
                  got: [1, 2, 3] (using ==)
      """
      And the output should contain:
      """
           Failure/Error: it { should match_array [1, 2, 1] }
             expected collection contained:  [1, 1, 2]
             actual collection contained:    [1, 2, 3]
             the missing elements were:      [1]
             the extra elements were:        [3]
      """

