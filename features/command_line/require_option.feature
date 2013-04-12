Feature: --require option

  Use the `--require` (or `-r`) option to specify a file to require
  before running specs.

  Scenario: using the --require option
    Given a file named "spec/foobarator.rb" with:
      """ruby
      class Foobarator; end
      """
    And a file named "spec/foobarator_spec.rb" with:
      """ruby
      describe Foobarator do
        it "exists" do
          expect(defined?(Foobarator)).to be_true
        end
      end
      """
    When I run `rspec --require foobarator`
    Then the output should contain "1 example, 0 failures"
