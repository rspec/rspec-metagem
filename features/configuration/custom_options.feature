@wip
Feature: custom options

  In order to seamlessly provide my users more options
  As an Rspec extenstion-library author
  I want to define new options on the Rspec.configuration

  Scenario: boolean option with default settings
    Given a file named "boolean_option_spec.rb" with:
      """
      Rspec.configure do |c|
        c.add_option :custom_option, :type => :boolean
      end

      describe "custom option" do
        it "is false by default" do
          Rspec.configuration.custom_option.should be_false
        end

        it "is exposed as a predicate" do
          Rspec.configuration.custom_option?.should be_false
        end
      end
      """
    When I run "rspec boolean_option_spec.rb"
    Then I should see "2 examples, 0 failures"

  Scenario: boolean option set to default to true
    Given a file named "boolean_option_spec.rb" with:
      """
      Rspec.configure do |c|
        c.add_option :custom_option, :type => :boolean, :default => true
      end

      describe "custom option" do
        it "is true by default" do
          Rspec.configuration.custom_option.should be_true
        end

        it "is exposed as a predicate" do
          Rspec.configuration.custom_option?.should be_true
        end
      end
      """
    When I run "rspec boolean_option_spec.rb"
    Then I should see "2 examples, 0 failures"

  Scenario: boolean option overridden in client app
    Given a file named "boolean_option_spec.rb" with:
      """
      Rspec.configure do |c|
        c.add_option :custom_option, :type => :boolean
      end

      Rspec.configure do |c|
        c.custom_option = :reset
      end

      describe "custom option" do
        it "returns the value set in the client app" do
          Rspec.configuration.custom_option.should == :reset
        end

        it "is exposed as a predicate" do
          Rspec.configuration.custom_option?.should be_true
        end
      end
      """
    When I run "rspec boolean_option_spec.rb"
    Then I should see "2 examples, 0 failures"

