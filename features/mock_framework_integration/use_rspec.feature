Feature: mock with rspec

  RSpec uses its own mocking framework by default, or you can configure it
  explicitly.

  Scenario: passing message expectation
    Given a file named "example_spec.rb" with:
      """ruby
      RSpec.configure do |config|
        config.mock_framework = :rspec
      end

      describe "mocking with RSpec" do
        it "passes when it should" do
          receiver = double('receiver')
          expect(receiver).to receive(:message)
          receiver.message
        end
      end
      """
    When I run `rspec example_spec.rb`
    Then the examples should all pass

  Scenario: failing message expecation
    Given a file named "example_spec.rb" with:
      """ruby
      RSpec.configure do |config|
        config.mock_framework = :rspec
      end

      describe "mocking with RSpec" do
        it "fails when it should" do
          receiver = double('receiver')
          expect(receiver).to receive(:message)
        end
      end
      """
    When I run `rspec example_spec.rb`
    Then the output should contain "1 example, 1 failure"

  Scenario: failing message expectation in pending example (remains pending)
    Given a file named "example_spec.rb" with:
      """ruby
      RSpec.configure do |config|
        config.mock_framework = :rspec
      end

      describe "failed message expectation in a pending example" do
        it "is listed as pending" do
          pending
          receiver = double('receiver')
          expect(receiver).to receive(:message)
        end
      end
      """
    When I run `rspec example_spec.rb`
    Then the output should contain "1 example, 0 failures, 1 pending"
    And the exit status should be 0

  Scenario: passing message expectation in pending example (fails)
    Given a file named "example_spec.rb" with:
      """ruby
      RSpec.configure do |config|
        config.mock_framework = :rspec
      end

      describe "passing message expectation in a pending example" do
        it "fails with FIXED" do
          pending
          receiver = double('receiver')
          expect(receiver).to receive(:message)
          receiver.message
        end
      end
      """
    When I run `rspec example_spec.rb`
    Then the output should contain "FIXED"
    Then the output should contain "1 example, 1 failure"
    And the exit status should be 1

  Scenario: accessing RSpec.configuration.mock_framework.framework_name
    Given a file named "example_spec.rb" with:
      """ruby
      RSpec.configure do |config|
        config.mock_framework = :rspec
      end

      describe "RSpec.configuration.mock_framework.framework_name" do
        it "returns :rspec" do
          expect(RSpec.configuration.mock_framework.framework_name).to eq(:rspec)
        end
      end
      """
    When I run `rspec example_spec.rb`
    Then the examples should all pass
