Feature: line number option

  Use the line number option to run a single example, or a single group.

  Scenario: standard examples
    Given a file named "example_spec.rb" with:
      """
      require "rspec/expectations"

      describe 9 do

        it "should be > 8" do
          9.should be > 8
        end

        it "should be < 10" do
          9.should be < 10
        end
        
      end
      """
    When I run "rspec example_spec.rb --line 5 --format doc"
    Then the output should contain "1 example, 0 failures"
    Then the output should contain "should be > 8"
    But the stdout should not contain "should be < 10"

  Scenario: one liner
    Given a file named "example_spec.rb" with:
      """
      require "rspec/expectations"

      describe 9 do

        it { should be > 8 }

        it { should be < 10 }
        
      end
      """
    When I run "rspec example_spec.rb --line 5 --format doc"
    Then the output should contain "1 example, 0 failures"
    Then the output should contain "should be > 8"
    But the stdout should not contain "should be < 10"
