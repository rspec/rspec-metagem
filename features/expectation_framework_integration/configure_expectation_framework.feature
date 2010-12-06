Feature: configure expectation framework

  By default, RSpec is configured to include rspec-expectations for expressing
  desired outcomes. You can also configure RSpec to use:

    rspec/expectations (explicitly)
    test/unit/assertions
    rspec/expecations _and_ test/unit assertions

  Scenario: configure rspec-expectations (explicitly)
    Given a file named "example_spec.rb" with:
      """
      RSpec.configure do |config|
        config.expect_with :rspec
      end

      describe 5 do
        it "is greater than 4" do
          5.should be > 4
        end
      end
      """
    When I run "rspec example_spec.rb"
    Then the output should contain "1 example, 0 failures"
    And the exit status should be 0

  Scenario: configure test/unit assertions
    Given a file named "example_spec.rb" with:
      """
      RSpec.configure do |config|
        config.expect_with :stdlib
      end

      describe 5 do
        it "is greater than 4" do
          assert 5 > 4, "expected 5 to be greater than 4"
        end
      end
      """
    When I run "rspec example_spec.rb"
    Then the output should contain "1 example, 0 failures"
    And the exit status should be 0

  Scenario: configure rspec/expecations AND test/unit assertions
    Given a file named "example_spec.rb" with:
      """
      RSpec.configure do |config|
        config.expect_with :rspec, :stdlib
      end

      describe 5 do
        it "is greater than 4" do
          assert 5 > 4, "expected 5 to be greater than 4"
        end

        it "is less than 4" do
          5.should be < 6
        end
      end
      """
    When I run "rspec example_spec.rb"
    Then the output should contain "2 examples, 0 failures"
    And the exit status should be 0
