Feature: spec/spec.opts

  For backwards compatibility with rspec-1, you can write command
  line options in a spec/spec.opts file and it will be loaded
  automatically.

  Options declared in spec/spec.opts will override configuration
  set up in Rspec.configure blocks.

  Background:
    Given a directory named "spec"

  Scenario: color set in Rspec.configure
    Given a file named "spec/spec_helper.rb" with:
      """
      require "rspec/expectations"
      Rspec.configure {|c| c.color_enabled = true }
      """
    And a file named "spec/example_spec.rb" with:
      """
      require "spec_helper"
      describe "color_enabled" do
        context "when set with Rspec.configure" do
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
      require "rspec/expectations"

      describe "color_enabled" do
        context "when set with Rspec.configure" do
          it "is true" do
            Rspec::Core.configuration.color_enabled?.should be_true
          end
        end
      end
      """
    When I run "rspec spec/example_spec.rb"
    Then the stdout should match "1 example, 0 failures"
            
  @wip
  Scenario: formatter set in both (spec.opts wins)
    Given a file named "spec/spec.opts" with:
      """
      --formatter documentation
      """
    And a file named "spec/spec_helper.rb" with:
      """
      require "rspec/expectations"
      Rspec.configure {|c| c.formatter = 'progress'}
      """
    And a file named "spec/example_spec.rb" with:
      """
      require "spec_helper"

      describe "formatter" do
        context "when set with Rspec.configure and in spec.opts" do
          it "takes the value set in spec.opts" do
            Rspec::Core.configuration.formatter.should be_an(Rspec::Core::Formatters::DocumentationFormatter)
          end
        end
      end
      """
    When I run "rspec spec/example_spec.rb"
    Then the stdout should match "1 example, 0 failures"

