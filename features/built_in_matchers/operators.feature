Feature: operator matchers

  RSpec provides a number of matchers that are based on Ruby's built-in
  operators. These pretty much work like you expect. For example, each of these
  pass:

    ```ruby
    expect(7).to == 7
    expect([1, 2, 3]).to == [1, 2, 3]
    expect("this is a string").to =~ /^this/
    expect("this is a string").not_to =~ /^that/
    expect(String).to === "this is a string"
    ```

  You can also use comparison operators combined with the "be" matcher like
  this:

    ```ruby
    expect(37).to be < 100
    expect(37).to be <= 38
    expect(37).to be >= 2
    expect(37).to be > 7
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
      describe 18 do
        it { should == 18 }
        it { should be < 20 }
        it { should be > 15 }
        it { should be <= 19 }
        it { should be >= 17 }

        it { should_not == 28 }

        # deliberate failures
        it { should == 28 }
        it { should be < 15 }
        it { should be > 20 }
        it { should be <= 17 }
        it { should be >= 19 }

        it { should_not == 18 }
      end
      """
     When I run `rspec numeric_operator_matchers_spec.rb`
     Then the output should contain "12 examples, 6 failures"
      And the output should contain:
      """
           Failure/Error: it { should == 28 }
             expected: 28
                  got: 18 (using ==)
      """
      And the output should contain:
      """
           Failure/Error: it { should be < 15 }
             expected: < 15
                  got:   18
      """
      And the output should contain:
      """
           Failure/Error: it { should be > 20 }
             expected: > 20
                  got:   18
      """
      And the output should contain:
      """
           Failure/Error: it { should be <= 17 }
             expected: <= 17
                  got:    18
      """
      And the output should contain:
      """
           Failure/Error: it { should be >= 19 }
             expected: >= 19
                  got:    18
      """
      And the output should contain:
      """
           Failure/Error: it { should_not == 18 }
             expected not: == 18
                      got:    18
      """

  Scenario: string operator matchers
    Given a file named "string_operator_matchers_spec.rb" with:
      """ruby
      describe "Strawberry" do
        it { should == "Strawberry" }
        it { should be < "Tomato" }
        it { should be > "Apple" }
        it { should be <= "Turnip" }
        it { should be >= "Banana" }
        it { should =~ /berry/ }

        it { should_not == "Peach" }
        it { should_not =~ /apple/ }

        it "reports that it is a string using ===" do
          expect(String).to be === subject
        end

        # deliberate failures
        it { should == "Peach" }
        it { should be < "Cranberry" }
        it { should be > "Zuchini" }
        it { should be <= "Potato" }
        it { should be >= "Tomato" }
        it { should =~ /apple/ }

        it { should_not == "Strawberry" }
        it { should_not =~ /berry/ }

        it "fails a spec asserting that it is a symbol" do
          expect(Symbol).to be === subject
        end
      end
      """
     When I run `rspec string_operator_matchers_spec.rb`
     Then the output should contain "18 examples, 9 failures"
      And the output should contain:
      """
           Failure/Error: it { should == "Peach" }
             expected: "Peach"
                  got: "Strawberry" (using ==)
      """
      And the output should contain:
      """
           Failure/Error: it { should be < "Cranberry" }
             expected: < "Cranberry"
                  got:   "Strawberry"
      """
      And the output should contain:
      """
           Failure/Error: it { should be > "Zuchini" }
             expected: > "Zuchini"
                  got:   "Strawberry"
      """
      And the output should contain:
      """
           Failure/Error: it { should be <= "Potato" }
             expected: <= "Potato"
                  got:    "Strawberry"
      """
      And the output should contain:
      """
           Failure/Error: it { should be >= "Tomato" }
             expected: >= "Tomato"
                  got:    "Strawberry"
      """
      And the output should contain:
      """
           Failure/Error: it { should =~ /apple/ }
             expected: /apple/
                  got: "Strawberry" (using =~)
      """
      And the output should contain:
      """
           Failure/Error: it { should_not == "Strawberry" }
             expected not: == "Strawberry"
                      got:    "Strawberry"
      """
      And the output should contain:
      """
           Failure/Error: it { should_not =~ /berry/ }
             expected not: =~ /berry/
                      got:    "Strawberry"
      """
      And the output should contain:
      """
           Failure/Error: expect(Symbol).to be === subject
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

