Feature: deprecation_io

  Define a custom output stream for warning about deprecations (default `$stderr`).

    RSpec.configure {|c| c.deprecation_io = File.open('saved_output', 'w') }

  or

    RSpec.configure {|c| c.log_deprecations_to_file 'saved_output' }

  Scenario: Redirecting an io stream
    Given a file named "spec/spec_helper.rb" with:
      """ruby
      RSpec.configure {|c| c.deprecation_io = File.open('saved_output', 'w') }
      """
    And a file named "spec/example_spec.rb" with:
      """ruby
      require 'spec_helper'
      describe "an example" do
        it "causes a deprecation" do
          RSpec.deprecate :method
        end
      end
      """
    When I run `rspec spec/example_spec.rb`
    Then the output should not contain "DEPRECATION"
    But the output should contain "There was 1 deprecation logged to #<File:saved_output>"
    And the file "saved_output" should contain "DEPRECATION: method is deprecated"

  Scenario: Redirecting to a specific file
    Given a file named "spec/spec_helper.rb" with:
      """ruby
      RSpec.configure {|c| c.log_deprecations_to_file 'saved_output' }
      """
    And a file named "spec/example_spec.rb" with:
      """ruby
      require 'spec_helper'
      describe "an example" do
        it "causes a deprecation" do
          RSpec.deprecate :method
        end
      end
      """
    When I run `rspec spec/example_spec.rb`
    Then the output should not contain "DEPRECATION"
    But the output should contain "There was 1 deprecation logged to saved_output"
    And the file "saved_output" should contain "DEPRECATION: method is deprecated"
