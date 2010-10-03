Feature: Operator Matchers

  RSpec provides a number of matchers that are based on Ruby's built-in
  operators.  These mostly work like you expect.  For example, each of these pass:

    * 7.should == 7
    * 25.2.should < 100
    * 8.should > 7
    * 17.should <= 17
    * 3.should >= 2
    * [1, 2, 3].should == [1, 2, 3]
    * "this is a string".should =~ /^this/
    * "this is a string".should_not =~ /^that/
    * String.should === "this is a string"

  RSpec also provides a `=~` matcher for arrays that disregards differences in
  the ording between the actual and expected array.  For example:

    * [1, 2, 3].should =~ [2, 3, 1] # pass
    * [:a, :c, :b].should =~ [:a, :c] # fail

  Scenario: numeric operator matchers
    Given a file named "numeric_operator_matchers_spec.rb" with:
      """
      describe 18 do
        it { should == 18 }
        it { should < 20 }
        it { should > 15 }
        it { should <= 19 }
        it { should >= 17 }

        it { should_not == 28 }
        it { should_not < 15 }
        it { should_not > 20 }
        it { should_not <= 17 }
        it { should_not >= 19 }

        # deliberate failures
        it { should == 28 }
        it { should < 15 }
        it { should > 20 }
        it { should <= 17 }
        it { should >= 19 }

        it { should_not == 18 }
        it { should_not < 20 }
        it { should_not > 15 }
        it { should_not <= 19 }
        it { should_not >= 17 }
      end
      """
     When I run "rspec numeric_operator_matchers_spec.rb"
     Then the output should contain "20 examples, 10 failures"
      And the output should contain:
      """
      Failures:
        1) 18 
           Failure/Error: it { should == 28 }
           expected: 28,
                got: 18 (using ==)
           # ./numeric_operator_matchers_spec.rb:15

        2) 18 
           Failure/Error: it { should < 15 }
           expected: < 15,
                got:   18
           # ./numeric_operator_matchers_spec.rb:16

        3) 18 
           Failure/Error: it { should > 20 }
           expected: > 20,
                got:   18
           # ./numeric_operator_matchers_spec.rb:17

        4) 18 
           Failure/Error: it { should <= 17 }
           expected: <= 17,
                got:    18
           # ./numeric_operator_matchers_spec.rb:18

        5) 18 
           Failure/Error: it { should >= 19 }
           expected: >= 19,
                got:    18
           # ./numeric_operator_matchers_spec.rb:19

        6) 18 
           Failure/Error: it { should_not == 18 }
           expected not: == 18,
                    got:    18
           # ./numeric_operator_matchers_spec.rb:21

        7) 18 
           Failure/Error: it { should_not < 20 }
           expected not: < 20,
                    got:   18
           # ./numeric_operator_matchers_spec.rb:22

        8) 18 
           Failure/Error: it { should_not > 15 }
           expected not: > 15,
                    got:   18
           # ./numeric_operator_matchers_spec.rb:23

        9) 18 
           Failure/Error: it { should_not <= 19 }
           expected not: <= 19,
                    got:    18
           # ./numeric_operator_matchers_spec.rb:24

        10) 18 
           Failure/Error: it { should_not >= 17 }
           expected not: >= 17,
                    got:    18
           # ./numeric_operator_matchers_spec.rb:25
      """

  Scenario: string operator matchers
    Given a file named "string_operator_matchers_spec.rb" with:
      """
      describe "Strawberry" do
        it { should == "Strawberry" }
        it { should < "Tomato" }
        it { should > "Apple" }
        it { should <= "Turnip" }
        it { should >= "Banana" }
        it { should =~ /berry/ }

        it { should_not == "Peach" }
        it { should_not < "Cranberry" }
        it { should_not > "Zuchini" }
        it { should_not <= "Potato" }
        it { should_not >= "Tomato" }
        it { should_not =~ /apple/ }

        it "reports that it is a string using ===" do
          String.should === subject
        end

        # deliberate failures
        it { should == "Peach" }
        it { should < "Cranberry" }
        it { should > "Zuchini" }
        it { should <= "Potato" }
        it { should >= "Tomato" }
        it { should =~ /apple/ }

        it { should_not == "Strawberry" }
        it { should_not < "Tomato" }
        it { should_not > "Apple" }
        it { should_not <= "Turnip" }
        it { should_not >= "Banana" }
        it { should_not =~ /berry/ }

        it "fails a spec asserting that it is a symbol" do
          Symbol.should === subject
        end
      end
      """
     When I run "rspec string_operator_matchers_spec.rb"
     Then the output should contain "26 examples, 13 failures"
      And the output should contain:
      """
      Failures:
        1) Strawberry 
           Failure/Error: it { should == "Peach" }
           expected: "Peach",
                got: "Strawberry" (using ==)
           # ./string_operator_matchers_spec.rb:21

        2) Strawberry 
           Failure/Error: it { should < "Cranberry" }
           expected: < "Cranberry",
                got:   "Strawberry"
           # ./string_operator_matchers_spec.rb:22

        3) Strawberry 
           Failure/Error: it { should > "Zuchini" }
           expected: > "Zuchini",
                got:   "Strawberry"
           # ./string_operator_matchers_spec.rb:23

        4) Strawberry 
           Failure/Error: it { should <= "Potato" }
           expected: <= "Potato",
                got:    "Strawberry"
           # ./string_operator_matchers_spec.rb:24

        5) Strawberry 
           Failure/Error: it { should >= "Tomato" }
           expected: >= "Tomato",
                got:    "Strawberry"
           # ./string_operator_matchers_spec.rb:25

        6) Strawberry 
           Failure/Error: it { should =~ /apple/ }
           expected: /apple/,
                got: "Strawberry" (using =~)
           Diff:
           @@ -1,2 +1,2 @@
           -/apple/
           +Strawberry
           # ./string_operator_matchers_spec.rb:26

        7) Strawberry 
           Failure/Error: it { should_not == "Strawberry" }
           expected not: == "Strawberry",
                    got:    "Strawberry"
           # ./string_operator_matchers_spec.rb:28

        8) Strawberry 
           Failure/Error: it { should_not < "Tomato" }
           expected not: < "Tomato",
                    got:   "Strawberry"
           # ./string_operator_matchers_spec.rb:29

        9) Strawberry 
           Failure/Error: it { should_not > "Apple" }
           expected not: > "Apple",
                    got:   "Strawberry"
           # ./string_operator_matchers_spec.rb:30

        10) Strawberry 
           Failure/Error: it { should_not <= "Turnip" }
           expected not: <= "Turnip",
                    got:    "Strawberry"
           # ./string_operator_matchers_spec.rb:31

        11) Strawberry 
           Failure/Error: it { should_not >= "Banana" }
           expected not: >= "Banana",
                    got:    "Strawberry"
           # ./string_operator_matchers_spec.rb:32

        12) Strawberry 
           Failure/Error: it { should_not =~ /berry/ }
           expected not: =~ /berry/,
                    got:    "Strawberry"
           Diff:
           @@ -1,2 +1,2 @@
           -/berry/
           +Strawberry
           # ./string_operator_matchers_spec.rb:33

        13) Strawberry fails a spec asserting that it is a symbol
           Failure/Error: Symbol.should === subject
           expected: "Strawberry",
                got: Symbol (using ===)
           Diff:
           @@ -1,2 +1,2 @@
           -Strawberry
           +Symbol
           # ./string_operator_matchers_spec.rb:36
      """

  Scenario: array operator matchers
    Given a file named "array_operator_matchers_spec.rb" with:
      """
      describe [1, 2, 3] do
        it { should == [1, 2, 3] }
        it { should_not == [1, 3, 2] }

        it { should =~ [1, 2, 3] }
        it { should =~ [1, 3, 2] }
        it { should =~ [2, 1, 3] }
        it { should =~ [2, 3, 1] }
        it { should =~ [3, 1, 2] }
        it { should =~ [3, 2, 1] }
        it { should_not =~ [1, 2, 1] }

        # deliberate failures
        it { should_not == [1, 2, 3] }
        it { should == [1, 3, 2] }

        it { should_not =~ [1, 2, 3] }
        it { should_not =~ [1, 3, 2] }
        it { should_not =~ [2, 1, 3] }
        it { should_not =~ [2, 3, 1] }
        it { should_not =~ [3, 1, 2] }
        it { should_not =~ [3, 2, 1] }
        it { should =~ [1, 2, 1] }
      end
      """
     When I run "rspec array_operator_matchers_spec.rb"
     Then the output should contain "18 examples, 9 failures"
      And the output should contain:
      """
      Failures:
        1) 123 
           Failure/Error: it { should_not == [1, 2, 3] }
           expected not: == [1, 2, 3],
                    got:    [1, 2, 3]
           Diff:
           # ./array_operator_matchers_spec.rb:14

        2) 123 
           Failure/Error: it { should == [1, 3, 2] }
           expected: [1, 3, 2],
                got: [1, 2, 3] (using ==)
           Diff:
           @@ -1,2 +1,2 @@
           -[1, 3, 2]
           +[1, 2, 3]
           # ./array_operator_matchers_spec.rb:15

        3) 123 
           Failure/Error: it { should_not =~ [1, 2, 3] }
           Matcher does not support should_not
           # ./array_operator_matchers_spec.rb:17

        4) 123 
           Failure/Error: it { should_not =~ [1, 3, 2] }
           Matcher does not support should_not
           # ./array_operator_matchers_spec.rb:18

        5) 123 
           Failure/Error: it { should_not =~ [2, 1, 3] }
           Matcher does not support should_not
           # ./array_operator_matchers_spec.rb:19

        6) 123 
           Failure/Error: it { should_not =~ [2, 3, 1] }
           Matcher does not support should_not
           # ./array_operator_matchers_spec.rb:20

        7) 123 
           Failure/Error: it { should_not =~ [3, 1, 2] }
           Matcher does not support should_not
           # ./array_operator_matchers_spec.rb:21

        8) 123 
           Failure/Error: it { should_not =~ [3, 2, 1] }
           Matcher does not support should_not
           # ./array_operator_matchers_spec.rb:22

        9) 123 
           Failure/Error: it { should =~ [1, 2, 1] }
           expected collection contained:  [1, 1, 2]
           actual collection contained:    [1, 2, 3]
           the missing elements were:      [1]
           the extra elements were:        [3]
           # ./array_operator_matchers_spec.rb:23
      """
