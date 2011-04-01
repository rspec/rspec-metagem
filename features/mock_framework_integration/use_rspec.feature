Feature: mock with rspec

  As an RSpec user who likes to mock
  I want to be able to use rspec

  Scenario: Mock with rspec
    Given a file named "rspec_example_spec.rb" with:
      """
      RSpec.configure do |config|
        config.mock_framework = :rspec
      end

      describe "plugging in rspec" do
        it "allows rspec to be used" do
          target = mock('target')
          target.should_receive(:foo)
          target.foo
        end

        describe "RSpec.configuration.mock_framework.framework_name" do
          it "returns :rspec" do
            RSpec.configuration.mock_framework.framework_name.should eq(:rspec)
          end
        end
      end
      """
    When I run `rspec ./rspec_example_spec.rb`
    Then the examples should all pass 
