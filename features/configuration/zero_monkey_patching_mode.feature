@allow-disabled-should-syntax
Feature: Zero monkey patching mode

  Use the `disable_monkey_patching!` configuration option to
  disable all monkey patching done by RSpec (stops exposing
  DSL globally, disabling should syntax for rspec-mocks and
  rspec-expectations):

  ```ruby
    RSpec.configure { |c| c.disable_monkey_patching! }
  ```

  Background:
    Given a file named "spec/example_describe_spec.rb" with:
      """ruby
      require 'spec_helper'

      describe "specs here" do
        it "passes" do
        end
      end
      """
    Given a file named "spec/example_should_spec.rb" with:
      """ruby
      require 'spec_helper'

      RSpec.describe "another specs here" do
        it "passes with monkey patched expectations" do
          x = 25
          x.should eq 25
          x.should_not be > 30
        end

        it "passes with monkey patched mocks" do
          x = double("thing")
          x.stub(:hello => [:world])
          x.should_receive(:count).and_return(5)
          x.should_not_receive(:all)
          (x.hello * x.count).should eq([:world] * 5)
        end
      end
      """
    Given a file named "spec/example_expect_spec.rb" with:
      """ruby
      require 'spec_helper'

      RSpec.describe "specs here too" do
        it "passes in zero monkey patching mode" do
          x = double("thing")
          allow(x).to receive(:hello).and_return([:world])
          expect(x).to receive(:count).and_return(5)
          expect(x).not_to receive(:all)
          expect(x.hello * x.count).to eq([:world] * 5)
        end

        it "passes in zero monkey patching mode" do
          x = 25
          expect(x).to eq(25)
          expect(x).not_to be > 30
        end
      end
      """

  Scenario: By default RSpec allows monkey patching
    Given a file named "spec/spec_helper.rb" with:
      """ruby
      """
    When I run `rspec spec/example_should_spec.rb`
    Then the examples should all pass

  Scenario: In zero monkey patching mode, the monkey patched methods are undefined
    Given a file named "spec/spec_helper.rb" with:
      """ruby
      RSpec.configure do |config|
        config.disable_monkey_patching!
      end
      """
    When I run `rspec spec/example_should_spec.rb`
    Then the output should contain all of these:
      | undefined method `should'   |
      | unexpected message :stub    |
    When I run `rspec spec/example_describe_spec.rb`
    Then the output should contain "undefined method `describe'"

  Scenario: Regardless of setting expect syntax works on mocks and expectations
    Given a file named "spec/spec_helper.rb" with:
      """ruby
      """
    When I run `rspec spec/example_expect_spec.rb`
    Then the examples should all pass
    Given a file named "spec/spec_helper.rb" with:
      """ruby
      RSpec.configure do |config|
        config.disable_monkey_patching!
      end
      """
    When I run `rspec spec/example_expect_spec.rb`
    Then the examples should all pass

