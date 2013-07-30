Feature: --dry-run

  Use the `--dry-run` option to tell RSpec to not to execute example code or any
  code in before/after(:each/:all) blocks.

  Background:
    Given a file named "dry_run_spec.rb" with:
      """ruby
      describe "dry run" do
        it "fails in example" do
          fail
        end
        context "fails in before(:all)" do
          before(:all) do
            fail
          end
          it "passing test" do; end
        end
        context "fails in after(:all)" do
          after(:all) do
            fail
          end
          it "passing test" do; end
        end
        context "fails in before(:each)" do
          before(:each) do
            fail
          end
          it "passing test" do; end
        end
        context "fails in after(:each)" do
          after(:each) do
            fail
          end
          it "passing test" do; end
        end
      end
      """

  Scenario: Using --dry-run
    When I run `rspec . --dry-run`
    Then the examples should all pass
