Feature: predicate matchers

  As an RSpec user
  I want to set expectations based upon the predicate methods of my objects
  So that I don't have to write a custom matcher for such a simple case

  Scenario: should be_zero (based on Fixnum#zero?)
    Given a file named "should_be_zero_spec.rb" with:
      """
      describe 0 do
        it { should be_zero }
      end

      describe 7 do
        it { should be_zero } # deliberately fail
      end
      """
    When I run "rspec ./should_be_zero_spec.rb"
    Then the output should contain "2 examples, 1 failure"
     And the output should contain "expected zero? to return true, got false"

  Scenario: should_not be_empty (based on Arrray#empty?)
    Given a file named "should_not_be_empty_spec.rb" with:
      """
      describe Array do
        context "with 3 items" do
          it "is not empty" do
            [1, 2, 3].should_not be_empty
          end
        end

        context "with no items" do
          it "is empty, but we'll fail this spec anyway" do
            [].should_not be_empty
          end
        end
      end
      """
    When I run "rspec ./should_not_be_empty_spec.rb"
    Then the output should contain "2 examples, 1 failure"
     And the output should contain "expected empty? to return false, got true"
