Feature: Test::Unit integration

  RSpec-expectations is a stand-alone gem that can be used without
  the rest of RSpec.  It can easily be used with another test
  framework such as Test::Unit if you like RSpec's should/should_not
  syntax but prefer the test organization of another framework.

  Scenario: Basic Test::Unit usage
    Given a file named "rspec_expectations_test.rb" with:
      """
      require 'test/unit'
      require 'rspec/expectations'

      class RSpecExpectationsTest < Test::Unit::TestCase
        def test_passing_expectation
          x = 1 + 3
          x.should == 4
        end

        def test_failing_expectation
          array = [1, 2]
          array.should be_empty
        end
      end
      """
     When I run "ruby rspec_expectations_test.rb"
     Then the output should contain "2 tests"
      And the output should contain "1 failure" or "1 error"
      And the output should contain "expected empty? to return true, got false"
