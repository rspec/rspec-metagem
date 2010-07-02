Feature: spec/spec.opts

  For backwards compatibility with rspec-1, you can write command
  line options in a spec/spec.opts file and it will be loaded
  automatically.

  Options declared in spec/spec.opts will override configuration
  set up in RSpec.configure blocks.

  Scenario: color set in RSpec.configure
    Given a file named "spec/example_spec.rb" with:
      """
      RSpec.configure {|c| c.color_enabled = true }

      describe "color_enabled" do
        context "when set with RSpec.configure" do
          it "is true" do
            RSpec.configuration.color_enabled?.should be_true
          end
        end
      end
      """
    When I run "rspec ./spec/example_spec.rb"
    Then the output should contain "1 example, 0 failures"
            
  Scenario: color set in .rspec
    Given a file named ".rspec" with:
      """
      --color
      """
    And a file named "spec/example_spec.rb" with:
      """
      describe "color_enabled" do
        context "when set with RSpec.configure" do
          it "is true" do
            RSpec.configuration.color_enabled?.should be_true
          end
        end
      end
      """
    When I run "rspec ./spec/example_spec.rb"
    Then the output should contain "1 example, 0 failures"

  Scenario: formatter set in both (RSpec.configure wins)
    Given a file named ".rspec" with:
      """
      --format progress
      """
    And a file named "spec/spec_helper.rb" with:
      """
      RSpec.configure {|c| c.formatter = 'documentation'}
      """
    And a file named "spec/example_spec.rb" with:
      """
      require "spec_helper"

      describe "formatter" do
        context "when set with RSpec.configure and in spec.opts" do
          it "takes the value set in spec.opts" do
            RSpec.configuration.formatter.should be_an(RSpec::Core::Formatters::DocumentationFormatter)
          end
        end
      end
      """
    When I run "rspec ./spec/example_spec.rb"
    Then the output should contain "1 example, 0 failures"

