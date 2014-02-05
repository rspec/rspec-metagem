Feature: --init option

  Use the --init option on the command line to generate conventional
  files for an rspec project. It generates a `.rspec` and
  `spec/spec_helper.rb` with some example settings to get you started.

  Scenario: generate .rspec
    When I run `rspec --init`
    Then the following files should exist:
      | .rspec |
    And the output should contain "create   .rspec"

  Scenario: .rspec file already exists
    Given a file named ".rspec" with:
      """
      --color
      """
    When I run `rspec --init`
    Then the output should contain "exist   .rspec"

  Scenario: Accept and use the recommended settings in spec_helper (which are initially commented out).
    Given I have a brand new project with no files
      And I have run `rspec --init`
     When I accept the recommended settings by removing `=begin` and `=end` from `spec/spec_helper.rb`
      And I create "spec/addition_spec.rb" with the following content:
        """ruby
        RSpec.describe "Addition" do
          it "works" do
            expect(1 + 1).to eq(2)
          end
        end
        """
      And I create "spec/subtraction_spec.rb" with the following content:
        """ruby
        RSpec.describe "Subtraction" do
          it "works" do
            expect(1 - 1).to eq(0)
          end
        end
        """

     When I run `rspec`
     Then the examples should all pass
      And the output should not contain:
        """
        Addition
          works
        """

     When I run `rspec spec/addition_spec.rb`
     Then the examples should all pass
      And the output should contain:
        """
        Addition
          works
        """

