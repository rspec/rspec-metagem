Feature: --dry-run

  Use the `--dry-run` option to tell RSpec to not to execute example code or any
  code in before/after(:each/:all) blocks.

  Scenario: Using --dry-run
    Given a file named "spec/dry_run_spec.rb" with:
      """ruby
      describe "dry run" do
        before(:all)  { fail }
        before(:each) { fail }

        it "fails in example" do
          fail
        end

        after(:each) { fail }
        after(:all)  { fail }
      end
      """
    When I run `rspec --dry-run`
    Then the output should contain "1 example, 0 failures"
