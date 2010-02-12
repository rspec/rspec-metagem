Feature: mock with rr

  As an RSpec user who likes to mock
  I want to be able to use rr

  Scenario: Mock with rr
    Given a file named "rr_example_spec.rb" with:
      """
      Rspec.configure do |config|
        config.mock_framework = :rr
      end

      describe "plugging in rr" do
        it "allows rr to be used" do
          target = Object.new
          mock(target).foo
          target.foo
        end
      end
      """
    When I run "spec rr_example_spec.rb"
    Then the stdout should match "1 example, 0 failures" 
    And the exit code should be 0
