Feature: pattern

  Use the `pattern` option to tell RSpec to look for specs in files that match
  a pattern other than `"**/*_spec.rb"`.

  Scenario: Override the default pattern in configuration
    Given a file named "spec/spec_helper.rb" with:
      """ruby
      RSpec.configure do |config|
        config.pattern << ',**/*.spec'
      end
      """
    And a file named "spec/example.spec" with:
      """ruby
      require 'spec_helper'
      RSpec.describe "something" do
        it "passes" do
        end
      end
      """
    When I run `rspec -rspec_helper`
    Then the output should contain "1 example, 0 failures"
