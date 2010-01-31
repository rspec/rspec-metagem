Feature: example name option

  Use the --example (or -e) option to filter the examples to be run by name.

  The submitted argument is compiled to a Ruby Regexp, and matched against the
  full description of the example, which is the concatenation of descriptions
  of the group (including any nested groups) and the example.

  This allows you to run a single uniquely named example, all examples with
  similar names, all the example in a uniquely named group, etc, etc.

  If no matches are found, then the entire suite is run.

  Background:
    Given a file named "first_spec.rb" with:
      """
      describe "first group" do
        it "first example in first group" do; end
        it "second example in first group" do; end
      end
      """
    Given a file named "second_spec.rb" with:
      """
      describe "second group" do
        it "first example in second group" do; end
        it "second example in second group" do; end
      end
      """

  Scenario: no matches
    When I run "spec . --example nothing_like_this"
    Then the stdout should match "4 examples, 0 failures"

  Scenario: all matches
    When I run "spec . --example example"
    Then the stdout should match "4 examples, 0 failures"

  Scenario: one match in each file
    When I run "spec . --example 'first example'"
    Then the stdout should match "2 examples, 0 failures"

  Scenario: one match in one file
    When I run "spec . --example 'first example in first group'"
    Then the stdout should match "1 example, 0 failures"

  Scenario: one match in one file using regexp
    When I run "spec . --example 'first .* first example'"
    Then the stdout should match "1 example, 0 failures"

  Scenario: all examples in one group
    When I run "spec . --example 'first group'"
    Then the stdout should match "2 examples, 0 failures"

  Scenario: one match in one file with group name
    When I run "spec . --example 'second group first example'"
    Then the stdout should match "1 example, 0 failures"
