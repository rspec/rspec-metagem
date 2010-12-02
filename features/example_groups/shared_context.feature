Feature: shared context

  Common setup, teardown, helper methods, etc, can be shared across example
  groups using a SharedContext: a Ruby Module that extends RSpec::SharedContext

  Scenario: share a helper method
    Given a file named "example_spec.rb" with:
      """
      module Helpers
        extend RSpec::SharedContext

        def helper_method
          "text from the helper method"
        end
      end

      describe "something" do
        include Helpers

        it "does something" do
          helper_method.should match(/^text from/)
        end
      end
      """
    When I run "rspec example_spec.rb"
    Then the examples should all pass

  Scenario: share before and after hooks
    Given a file named "example_spec.rb" with:
      """
      module Shared
        extend RSpec::SharedContext

        before(:all)  { puts "before all" }
        before(:each) { puts "before each" }
        after(:each)  { puts "after each" }
        after(:all)   { puts "after all" }
      end

      describe "something" do
        include Shared
        example { puts "example" }
      end
      """
    When I run "rspec example_spec.rb"
    And the output should contain:
      """
      before all
      before each
      example
      after each
      .after all
      """
