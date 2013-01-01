Feature: drb and drb port

  Using the drb option and the drb_port option, users can run examples over DRb and set the port for that server.

  Scenario: DRb is off by default
    Given a file named "spec/example_spec.rb" with:
      """ruby
      describe "DRb status" do
        it "is false" do
          RSpec.configuration.drb?.should be_false
        end
      end
      """
    When I run `rspec spec/example_spec.rb`
    Then the examples should all pass

  Scenario: when DRb is turned on
    Given a file named "spec/example_spec.rb" with:
      """ruby
      RSpec.configure do |c|
         c.drb = true
      end

      describe "DRb status" do
        it "is true" do
          RSpec.configuration.drb?.should be_true
        end
      end
      """
    When I run `rspec spec/example_spec.rb`
    Then the examples should all pass

  Scenario: the default DRb port
    Given a file named "spec/example_spec.rb" with:
      """ruby
      RSpec.configure do |c|
         c.drb = true
      end

      describe "DRb port" do
        it "is not set (is nil) by default" do
          RSpec.configuration.drb_port.should be_nil
        end
      end
      """
    When I run `rspec spec/example_spec.rb`
    Then the examples should all pass

  Scenario: setting the DRb port
    Given a file named "spec/example_spec.rb" with:
      """ruby
      RSpec.configure do |c|
         c.drb = true
         c.drb_port = 42
      end

      describe "DRb port" do
        it "is what I set it to" do
          RSpec.configuration.drb_port.should == 42
        end
      end
      """
    When I run `rspec spec/example_spec.rb`
    Then the examples should all pass
