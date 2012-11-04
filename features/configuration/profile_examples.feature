Feature: profile examples

  Use the profile_examples option to tell RSpec to report the times
  for the 10 slowest examples.

    RSpec.configure { |c| c.profile_examples = true }

  Background:
    Given a file named "spec/spec_helper.rb" with:
      """ruby
      RSpec.configure { |c| c.profile_examples = true }
      """

  Scenario: profile_examples defaults to false
    Given a file named "spec/example_spec.rb" with:
      """ruby
      describe "something" do
        it "passes" do
        end

        it "also passes" do
        end
      end
      """
   When I run `rspec spec/example_spec.rb`
   Then the output should not contain "Top 2 slowest examples"

  Scenario: profile_examples reports on the slowest features
    Given a file named "spec/example_spec.rb" with:
      """ruby
      require 'spec_helper'
      describe "something" do
        it "passes" do
        end

        it "also passes" do
        end
      end
      """
   When I run `rspec spec/example_spec.rb`
   Then the output should contain "Top 2 slowest examples"
