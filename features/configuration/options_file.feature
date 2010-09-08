Feature: options file
  
  To load in configuration options from a file, RSpec will look
  for a ".rspec" file.
  
  There are two types of ".rspec" files: local and global. Local
  exists in the project root directory, while global exists in
  the system root directory (~). Examples:
  
    Local:  "~/path/to/project/.rspec"
    Global: "~/.rspec"

  The local file will override the global file, while options
  declared in RSpec.configure will override any ".rspec" file.
  
  NOTE: For backwards compatibility with rspec-1, you can write
  command line options in a "spec/spec.opts" file and it will be
  loaded automatically.
            
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
            RSpec.configuration.should be_color_enabled
          end
        end
      end
      """
    When I run "rspec ./spec/example_spec.rb"
    Then the output should contain "1 example, 0 failures"

  Scenario: formatter set in RSpec.configure overrides .rspec
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
    
  Scenario: using ERB in .rspec
    Given a file named ".rspec" with:
      """
      --format <%= true ? 'documentation' : 'progress' %>
      """
    And a file named "spec/example_spec.rb" with:
      """
      describe "formatter" do
        it "is set to documentation" do
          RSpec.configuration.formatter.should be_an(RSpec::Core::Formatters::DocumentationFormatter)
        end
      end
      """
    When I run "rspec ./spec/example_spec.rb"
    Then the output should contain "1 example, 0 failures"