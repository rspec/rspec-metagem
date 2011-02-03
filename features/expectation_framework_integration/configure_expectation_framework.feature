Feature: configure expectation framework

  By default, RSpec is configured to include rspec-expectations for expressing
  desired outcomes. You can also configure RSpec to use:

  * rspec/expectations (explicitly)
  * stdlib assertions
    * test/unit assertions in ruby 1.8
    * minitest assertions in ruby 1.9
  * rspec/expecations _and_ stlib assertions

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
    Then the examples should all pass

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
    Then the examples should all pass

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
    Then the examples should all pass
