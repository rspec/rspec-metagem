Feature: profile examples

  Use the profile_count option to tell RSpec have many specs to include in the profile:

      RSpec.configure { |c| c.profile_examples = 15 }

  Background:
    Given a file named "spec/spec_helper.rb" with:
      """ruby
      """
    And a file named "spec/example_spec.rb" with:
      """ruby
      require "spec_helper"

      describe "something" do
        it "foos take longest" do
          sleep 0.1
          1.should == 1
        end

        it "bars are quick" do
          2.should == 2
        end

        it "bazzes take longer" do
          sleep 0.15
          3.should == 3
        end

        it "bims are also quick" do
          sleep 0.05
          4.should == 4
        end

        it "fifth example" do
          sleep 0.05
          5.should == 5
        end

        it "sixth example" do
          sleep 0.05
          6.should == 6
        end

        it "seventh example" do
          sleep 0.05
          7.should == 7
        end

        it "eight example" do
          sleep 0.05
          8.should == 8
        end

        it "ninth example" do
          sleep 0.05
          9.should == 9
        end

        it "tenth example" do
          sleep 0.05
          10.should == 10
        end

        it "eleventh example" do
          sleep 0.05
          11.should == 11
        end
      end
      """

  Scenario: by default does not show profile
    When I run `rspec spec`
    Then the examples should all pass
    And the output should not contain "bazzes take longer"
    And the output should not contain "foos take longest"
    And the output should not contain "bars are quick"
    And the output should not contain "bims are also quick"

  Scenario: setting `profile_examples` to true shows 10 examples
    Given a file named "spec/spec_helper.rb" with:
      """ruby
      RSpec.configure { |c| c.profile_examples = true }
      """
    When I run `rspec spec`
    Then the examples should all pass
    And the output should contain "bazzes take longer"
    And the output should contain "foos take longest"
    And the output should contain "bims are also quick"
    And the output should contain "fifth example"
    And the output should contain "sixth example"
    And the output should contain "seventh example"
    And the output should contain "eight example"
    And the output should contain "ninth example"
    And the output should contain "tenth example"
    And the output should contain "eleventh example"
    And the output should not contain "bars are quick"

  Scenario: setting `profile_examples` to 2 shows 2 examples
    Given a file named "spec/spec_helper.rb" with:
      """ruby
      RSpec.configure { |c| c.profile_examples = 2 }
      """
    When I run `rspec spec`
    Then the examples should all pass
    And the output should contain "bazzes take longer"
    And the output should contain "foos take longest"
    And the output should not contain "bars are quick"
    And the output should not contain "bims are also quick"
