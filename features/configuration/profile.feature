Feature: profile example count

  Use the profile_count option to tell RSpec have many specs to include in the profile:

      RSpec.configure { |c| c.profile_example_count = 15 }

  Background:
    Given a file named "spec/spec_helper.rb" with:
      """ruby
      RSpec.configure { |c| c.profile_example_count = 2 }
      """

  Scenario: profile shows 2 examples
    Given a file named "spec/example_spec.rb" with:
      """ruby
      require "spec_helper"

      describe "something" do
        it "foos take longest" do
          container = Array.new
          100_000.times { |n| container << n }
          container.should include 3
        end

        it "bars are quick" do
          "bar".should == "bar"
        end

        it "bazzes take longer" do
          container = Array.new
          10_000.times { |n| container << n }
          container.should include 3
        end

        it "bims are also quick" do
          1.should == 1
        end
      end
      """
    When I run `rspec spec --profile`
    Then the examples should all pass
    And the output should contain "bazzes take longer"
    And the output should contain "foos take longest"
    And the output should not contain "bars are quick"
    And the output should not contain "bims are also quick"
