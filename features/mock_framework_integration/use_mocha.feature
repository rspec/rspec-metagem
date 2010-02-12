Feature: mock with mocha

  As an RSpec user who likes to mock
  I want to be able to use mocha

  Scenario: Mock with mocha
    Given a file named "mocha_example_spec.rb" with:
      """
      Rspec.configure do |config|
        config.mock_framework = :mocha
      end

      describe "plugging in mocha" do
        it "allows mocha to be used" do
          target = Object.new
          target.expects(:foo).once
          target.foo
        end
      end
      """
    When I run "spec mocha_example_spec.rb"
    Then the stdout should match "1 example, 0 failures" 
    And the exit code should be 0
