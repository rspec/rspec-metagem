Feature: example name option

  Use the --example (or -e) option to filter the examples
  to be run by name.

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

  Scenario: one match in one file with group name
    When I run "spec . --example 'second group first example'"
    Then the stdout should match "1 example, 0 failures"
