Feature: custom settings

  Extensions like rspec-rails can add their own configuration settings.

  Scenario: simple setting (with defaults)
    Given a file named "additional_setting_spec.rb" with:
      """ruby
      RSpec.configure do |c|
        c.add_setting :custom_setting
      end

      describe "custom setting" do
        it "is nil by default" do
          expect(RSpec.configuration.custom_setting).to be_nil
        end

        it "acts false by default" do
          expect(RSpec.configuration.custom_setting).to be_falsey
        end

        it "is exposed as a predicate" do
          expect(RSpec.configuration.custom_setting?).to be_falsey
        end

        it "can be overridden" do
          RSpec.configuration.custom_setting = true
          expect(RSpec.configuration.custom_setting).to be_truthy
          expect(RSpec.configuration.custom_setting?).to be_truthy
        end
      end
      """
    When I run `rspec ./additional_setting_spec.rb`
    Then the examples should all pass

  Scenario: default to true
    Given a file named "additional_setting_spec.rb" with:
      """ruby
      RSpec.configure do |c|
        c.add_setting :custom_setting, :default => true
      end

      describe "custom setting" do
        it "is true by default" do
          expect(RSpec.configuration.custom_setting).to be_truthy
        end

        it "is exposed as a predicate" do
          expect(RSpec.configuration.custom_setting?).to be_truthy
        end

        it "can be overridden" do
          RSpec.configuration.custom_setting = false
          expect(RSpec.configuration.custom_setting).to be_falsey
          expect(RSpec.configuration.custom_setting?).to be_falsey
        end
      end
      """
    When I run `rspec ./additional_setting_spec.rb`
    Then the examples should all pass

  Scenario: overridden in a subsequent RSpec.configure block
    Given a file named "additional_setting_spec.rb" with:
      """ruby
      RSpec.configure do |c|
        c.add_setting :custom_setting
      end

      RSpec.configure do |c|
        c.custom_setting = true
      end

      describe "custom setting" do
        it "returns the value set in the last cofigure block to get eval'd" do
          expect(RSpec.configuration.custom_setting).to be_truthy
        end

        it "is exposed as a predicate" do
          expect(RSpec.configuration.custom_setting?).to be_truthy
        end
      end
      """
    When I run `rspec ./additional_setting_spec.rb`
    Then the examples should all pass

