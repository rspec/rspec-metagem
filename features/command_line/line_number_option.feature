Feature: line number option

  As an Rspec user
  I want to run one example identified by the line number
  
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
    When I run "spec example_spec.rb --line 5 --format doc"
    Then the stdout should match "1 example, 0 failures"
    Then the stdout should match "should be > 8"
    But the stdout should not match "should be < 10"

  Scenario: one liner
    Given a file named "example_spec.rb" with:
      """
      require "rspec/expectations"

      describe 9 do

        it { should be > 8 }

        it { should be < 10 }
        
      end
      """
    When I run "spec example_spec.rb --line 5 --format doc"
    Then the stdout should match "1 example, 0 failures"
    Then the stdout should match "should be > 8"
    But the stdout should not match "should be < 10"
