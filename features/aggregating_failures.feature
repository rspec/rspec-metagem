@wip @announce
Feature: Aggregating Failures

  Normally, an expectation failure causes the example to immediately bail.  Sometimes, however, you have multiple, independent expectations, and you'd like to be able to see all of the failures rather than just the first.  One solution is to split off a separate example for each expectation, but if the setup for the examples is slow, that's going to take extra time and slow things down. `aggregate_failures` provides an alternate solution. Within the block, expectation failures will not abort the example like normal; instead, the failures will be aggregated into a single exception that is raised at the end of the block, allowing you to see all expectations that failed.

  `aggregate_failures` takes an optional string argument that will be used in the aggregated failure message as a label.

  Scenario: Multiple Expectation Failures in the same example are all reported
    Given a file named "spec/aggregated_failure_spec.rb" with:
      """ruby
      RSpec.describe "An aggregated failure" do
        it "lists each of the individual failures in the failure output" do
          aggregate_failures "testing equality" do
            expect(1).to eq(2)
            expect(2).to eq(3)
            expect(3).to eq(4)
          end
        end
      end
      """
    When I run `rspec spec/aggregated_failure_spec.rb`
    Then it should fail listing all the failures:
      """
      Failures:

        1) An aggregated failure lists each of the individual failures in the failure output
           Got 3 failures from failure aggregation block "testing equality".
           # ./spec/aggregated_failure_spec.rb:3:in `block (2 levels) in <top (required)>'

           1.1) Failure/Error: expect(1).to eq(2)

                  expected: 2
                       got: 1

                  (compared using ==)
                # ./spec/aggregated_failure_spec.rb:4:in `block (3 levels) in <top (required)>'

           1.2) Failure/Error: expect(2).to eq(3)

                  expected: 3
                       got: 2

                  (compared using ==)
                # ./spec/aggregated_failure_spec.rb:5:in `block (3 levels) in <top (required)>'

           1.3) Failure/Error: expect(3).to eq(4)

                  expected: 4
                       got: 3

                  (compared using ==)
                # ./spec/aggregated_failure_spec.rb:6:in `block (3 levels) in <top (required)>'
      """

  Scenario: Use `:aggregated_failures` metadata
    Given a file named "spec/aggregated_failure_spec.rb" with:
      """ruby
      RSpec.describe "An aggregated failure" do
        it "lists each of the individual failures in the failure output", :aggregate_failures do
          expect(1).to eq(2)
          expect(2).to eq(3)
          expect(3).to eq(4)
        end
      end
      """
    When I run `rspec spec/aggregated_failure_spec.rb`
    Then it should fail listing all the failures:
      """
      Failures:

        1) An aggregated failure lists each of the individual failures in the failure output
           Got 3 failures:

           1.1) Failure/Error: expect(1).to eq(2)

                  expected: 2
                       got: 1

                  (compared using ==)
                # ./spec/aggregated_failure_spec.rb:3:in `block (3 levels) in <top (required)>'

           1.2) Failure/Error: expect(2).to eq(3)

                  expected: 3
                       got: 2

                  (compared using ==)
                # ./spec/aggregated_failure_spec.rb:4:in `block (3 levels) in <top (required)>'

           1.3) Failure/Error: expect(3).to eq(4)

                  expected: 4
                       got: 3

                  (compared using ==)
                # ./spec/aggregated_failure_spec.rb:5:in `block (3 levels) in <top (required)>'
      """
