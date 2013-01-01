Feature: Profile examples

  The `--profile` command line option (available from `RSpec.configure` as
  `#profile_examples`), when set, will cause RSpec to dump out a list of
  your slowest examples. By default, it prints the 10 slowest examples,
  but you can set it to a different value to have it print more or fewer
  slow examples.

  Background:
    Given a file named "spec/spec_helper.rb" with:
      """ruby
      """
    And a file named "spec/example_spec.rb" with:
      """ruby
      require "spec_helper"

      describe "something" do
        it "sleeps for 0.1 secionds (example 1)" do
          sleep 0.1
          1.should == 1
        end

        it "sleeps for 0 seconds (example 2)" do
          2.should == 2
        end

        it "sleeps for 0.15 seconds (example 3)" do
          sleep 0.15
          3.should == 3
        end

        it "sleeps for 0.05 seconds (example 4)" do
          sleep 0.05
          4.should == 4
        end

        it "sleeps for 0.05 seconds (example 5)" do
          sleep 0.05
          5.should == 5
        end

        it "sleeps for 0.05 seconds (example 6)" do
          sleep 0.05
          6.should == 6
        end

        it "sleeps for 0.05 seconds (example 7)" do
          sleep 0.05
          7.should == 7
        end

        it "sleeps for 0.05 seconds (example 8)" do
          sleep 0.05
          8.should == 8
        end

        it "sleeps for 0.05 seconds (example 9)" do
          sleep 0.05
          9.should == 9
        end

        it "sleeps for 0.05 seconds (example 10)" do
          sleep 0.05
          10.should == 10
        end

        it "sleeps for 0.05 seconds (example 11)" do
          sleep 0.05
          11.should == 11
        end
      end
      """

  Scenario: by default does not show profile
    When I run `rspec spec`
    Then the examples should all pass
    And the output should not contain "example 1"
    And the output should not contain "example 2"
    And the output should not contain "example 3"
    And the output should not contain "example 4"
    And the output should not contain "example 5"
    And the output should not contain "example 6"
    And the output should not contain "example 7"
    And the output should not contain "example 8"
    And the output should not contain "example 9"
    And the output should not contain "example 10"
    And the output should not contain "example 11"

  Scenario: setting `profile_examples` to true shows 10 examples
    Given a file named "spec/spec_helper.rb" with:
      """ruby
      RSpec.configure { |c| c.profile_examples = true }
      """
    When I run `rspec spec`
    Then the examples should all pass
    And the output should contain "Top 10 slowest examples"
    And the output should contain "example 1"
    And the output should not contain "example 2"
    And the output should contain "example 3"
    And the output should contain "example 4"
    And the output should contain "example 5"
    And the output should contain "example 6"
    And the output should contain "example 7"
    And the output should contain "example 8"
    And the output should contain "example 9"
    And the output should contain "example 10"
    And the output should contain "example 11"

  Scenario: setting `profile_examples` to 2 shows 2 examples
    Given a file named "spec/spec_helper.rb" with:
      """ruby
      RSpec.configure { |c| c.profile_examples = 2 }
      """
    When I run `rspec spec`
    Then the examples should all pass
    And the output should contain "Top 2 slowest examples"
    And the output should contain "example 1"
    And the output should not contain "example 2"
    And the output should contain "example 3"
    And the output should not contain "example 4"
    And the output should not contain "example 5"
    And the output should not contain "example 6"
    And the output should not contain "example 7"
    And the output should not contain "example 8"
    And the output should not contain "example 9"
    And the output should not contain "example 10"
    And the output should not contain "example 11"

  Scenario: setting profile examples through CLI
    When I run `rspec spec --profile 2`
    Then the examples should all pass
    And the output should contain "Top 2 slowest examples"
    And the output should contain "example 1"
    And the output should not contain "example 2"
    And the output should contain "example 3"
    And the output should not contain "example 4"
    And the output should not contain "example 5"
    And the output should not contain "example 6"
    And the output should not contain "example 7"
    And the output should not contain "example 8"
    And the output should not contain "example 9"
    And the output should not contain "example 10"
    And the output should not contain "example 11"

  Scenario: Using `--no-profile` overrules config options
    Given a file named "spec/spec_helper.rb" with:
      """ruby
      RSpec.configure { |c| c.profile_examples = true }
      """
    When I run `rspec spec --no-profile`
    Then the examples should all pass
    And the output should not contain "example 1"
    And the output should not contain "example 2"
    And the output should not contain "example 3"
    And the output should not contain "example 4"
    And the output should not contain "example 5"
    And the output should not contain "example 6"
    And the output should not contain "example 7"
    And the output should not contain "example 8"
    And the output should not contain "example 9"
    And the output should not contain "example 10"
    And the output should not contain "example 11"

