Feature: spec/spec.opts

  For backwards compatibility with rspec-1, you can write command
  line options in a spec/spec.opts file and it will be loaded
  automatically.

  Options declared in spec/spec.opts will override configuration
  set up in Rspec::Core.configure blocks.

  Background:
    Given a directory named "spec"

  Scenario: color set in Rspec::Core.configure
    Given a file named "spec/spec_helper.rb" with:
      """
      Rspec::Core.configure do |c|
        c.color_enabled = true
      end
      """
    And a file named "spec/example_spec.rb" with:
      """
      require "spec_helper"
      describe "color_enabled" do
        context "when set with Rspec::Core.configure" do
          it "is true" do
            Rspec::Core.configuration.color_enabled?.should be_true
          end
        end
      end
      """
    When I run "rspec spec/example_spec.rb"
    Then the stdout should match "1 example, 0 failures"
            
  Scenario: color set in spec/spec.opts
    Given a file named "spec/spec.opts" with:
      """
      --color
      """
    And a file named "spec/example_spec.rb" with:
      """
      describe "color_enabled" do
        context "when set with Rspec::Core.configure" do
          it "is true" do
            Rspec::Core.configuration.color_enabled?.should be_true
          end
        end
      end
      """
    When I run "rspec spec/example_spec.rb"
    Then the stdout should match "1 example, 0 failures"
            
  Scenario: formatter set in both (spec.opts wins)
    Given a file named "spec/spec.opts" with:
      """
      --formatter documentation
      """

    And a file named "spec/spec_helper.rb" with:
      """
      Rspec::Core.configure do |c|
        c.formatter = 'pretty'
      end
      """
    And a file named "spec/example_spec.rb" with:
      """
      describe "formatter" do
        context "when set with Rspec::Core.configure and in spec.opts" do
          it "takes the value set in spec.opts" do
            Rspec::Core.configuration.formatter.should be_an(Rspec::Core::Formatters::DocumentationFormatter)
          end
        end
      end
      """
    When I run "rspec spec/example_spec.rb"
    Then the stdout should match "1 example, 0 failures"

