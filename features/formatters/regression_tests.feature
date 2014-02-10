Feature: Regression tests for legacy custom formatters

  Background:
    Given a file named ".rspec" with:
      """
      --require spec_helper
      """
      And a file named "spec/spec_helper.rb" with:
      """
      RSpec.configure do |rspec|
        rspec.after(:suite) do
          puts rspec.formatters.map(&:class).inspect
        end
      end
      """
      And a file named "spec/passing_and_failing_spec.rb" with:
      """ruby
      RSpec.describe "Some examples" do
        it "passes" do
          expect(1).to eq(1)
        end

        it "fails" do
          expect(1).to eq(2)
        end

        context "nested" do
          it "passes" do
            expect(1).to eq(1)
          end

          it "fails" do
            expect(1).to eq(2)
          end
        end
      end
      """
      And a file named "spec/pending_spec.rb" with:
      """ruby
      RSpec.describe "Some pending examples" do
        context "pending" do
          it "is reported as pending" do
            pending; expect(1).to eq(2)
          end

          it "is reported as failing" do
            pending; expect(1).to eq(1)
          end
        end
      end
      """

  Scenario: Use fuubar formatter
    When I run `rspec --format Fuubar`
    Then the output should contain "Progress: |============"
     And the output should contain "6 examples, 3 failures, 1 pending"
     And the output should contain "The Fuubar formatter uses the deprecated formatter interface"
     But the output should not contain any error backtraces
     And the output should not contain "ProgressFormatter"

  Scenario: Use rspec-instafail formatter
    When I run `rspec --format RSpec::Instafail`
    Then the output should contain "6 examples, 3 failures, 1 pending"
     And the output should contain "The RSpec::Instafail formatter uses the deprecated formatter interface"
     But the output should not contain any error backtraces
     And the output should not contain "ProgressFormatter"

  Scenario: Use rspec-extra-formatters JUnit formatter
    When I run `rspec --require rspec-extra-formatters --format JUnitFormatter`
    Then the output should contain:
      """
      <testsuite errors="0" failures="3" skipped="1" tests="6"
      """
     And the output should contain "The JUnitFormatter formatter uses the deprecated formatter interface"
     But the output should not contain any error backtraces
     And the output should not contain "ProgressFormatter"

  @wip @announce
  Scenario: Use rspec-extra-formatters Tap formatter
    When I run `rspec --require rspec-extra-formatters --format TapFormatter`
    Then the output should contain "TAP version 13"
     And the output should contain "The TapFormatter formatter uses the deprecated formatter interface"
     But the output should not contain any error backtraces
     And the output should not contain "ProgressFormatter"

  @wip @announce
  Scenario: Use rspec-spinner formatter
    When I run `rspec --require rspec_spinner --format RspecSpinner::Spinner`
    Then the output should contain "TBD"

  @wip @announce
  Scenario: Use nyancat formatter
    When I run `rspec --format NyanCatFormatter`
    Then the output should contain "TBD"

