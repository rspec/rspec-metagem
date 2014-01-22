Feature: Minitest integration

  rspec-expectations is a stand-alone gem that can be used without the rest of
  RSpec. If you like minitest as your test runner, but prefer RSpec's
  approach to expressing expectations, you can have both.

  To integrate rspec-expectations with minitest, require `rspec/expectations/minitest_integration`.

  Scenario: use rspec/expectations with minitest
    Given a file named "rspec_expectations_test.rb" with:
      """ruby
      require 'minitest/autorun'
      require 'rspec/expectations/minitest_integration'

      class RSpecExpectationsTest < Minitest::Test
        RSpec::Matchers.define :be_an_integer do
          match { |actual| Integer === actual }
        end

        def be_an_int
          # This is actually an internal rspec-expectations API, but is used
          # here to demonstrate that deprecation warnings from within
          # rspec-expectations work correcty without depending on rspec-core
          RSpec.deprecate(:be_an_int, :replacement => :be_an_integer)
          be_an_integer
        end

        def test_passing_expectation
          expect(1 + 3).to eq 4
        end

        def test_failing_expectation
          expect([1, 2]).to be_empty
        end

        def test_custom_matcher_with_deprecation_warning
          expect(1).to be_an_int
        end
      end
      """
     When I run `ruby rspec_expectations_test.rb`
     Then the output should contain "3 runs, 3 assertions, 1 failures, 0 errors"
      And the output should contain "expected empty? to return true, got false"
      And the output should contain "be_an_int is deprecated"
