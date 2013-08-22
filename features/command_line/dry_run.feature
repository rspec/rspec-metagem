Feature: --dry-run

  Use the `--dry-run` option to tell RSpec to not to execute example code or any
  code in before/after(:each/:all) blocks.

  Background:
    Given a file named "dry_run_spec.rb" with:
      """ruby
      describe "dry run" do
        before(:all) do; fail; end
        before(:each) do; fail; end
        it "fails in example" do
          fail
        end
        after(:each) do; fail; end
        after(:all) do fail; end
      end
      """

  Scenario: Using --dry-run
    When I run `rspec . --dry-run`
    Then the output should contain "1 example, 0 failures"
