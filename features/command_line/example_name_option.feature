Feature: example name option

  Use the --example (or -e) option to filter the examples to be run by name.

  The argument is compiled to a Ruby Regexp, and matched against the full
  description of the example, which is the concatenation of descriptions of the
  group (including any nested groups) and the example.

  This allows you to run a single uniquely named example, all examples with
  similar names, all the example in a uniquely named group, etc, etc.

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
    When I run "rspec . --example nothing_like_this"
    Then I should see "0 examples, 0 failures"

  Scenario: match on one word
    When I run "rspec . --example example"
    Then I should see "4 examples, 0 failures"

  Scenario: one match in each file
    When I run "rspec . --example 'first example'"
    Then I should see "2 examples, 0 failures"

  Scenario: one match in one file using just the example name
    When I run "rspec . --example 'first example in first group'"
    Then I should see "1 example, 0 failures"

  Scenario: one match in one file using the example name and the group name
    When I run "rspec . --example 'first group first example in first group'"
    Then I should see "1 example, 0 failures"

  Scenario: one match in one file using regexp
    When I run "rspec . --example 'first .* first example'"
    Then I should see "1 example, 0 failures"

  Scenario: all examples in one group
    When I run "rspec . --example 'first group'"
    Then I should see "2 examples, 0 failures"

  Scenario: one match in one file with group name
    When I run "rspec . --example 'second group first example'"
    Then I should see "1 example, 0 failures"
