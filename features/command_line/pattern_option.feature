Feature: `--pattern` option

  By default, RSpec loads files matching the pattern:
    `"spec/**/*_spec.rb"`

  Use the `--pattern` option to declare a different pattern.

  Background:
    Given a file named "spec/example_spec.rb" with:
      """ruby
      RSpec.describe "two specs" do
        it "passes" do
        end

        it "passes too" do
        end
      end
      """
    And a file named "spec/example_test.rb" with:
      """ruby
      RSpec.describe "one spec" do
        it "passes" do
        end
      end
      """

  Scenario: By default, RSpec runs files that match `"**/*_spec.rb"`
   When I run `rspec`
   Then the output should contain "2 examples, 0 failures"

  Scenario: The `--pattern` flag makes RSpec run files matching the specified pattern and ignore the default pattern
   When I run `rspec -P "**/*_test.rb"`
   Then the output should contain "1 example, 0 failures"

  Scenario: The `--pattern` flag can be used to pass in multiple patterns, separated by commas
   When I run `rspec -P "**/*_test.rb,**/*_spec.rb"`
   Then the output should contain "3 examples, 0 failures"

  Scenario: The `--pattern` flag accepts shell style glob unions
   When I run `rspec -P "**/*_{test,spec}.rb"`
   Then the output should contain "3 examples, 0 failures"
