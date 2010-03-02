Feature: described class

  Scenario: access the described class from the example
    Given a file named "spec/example_spec.rb" with:
      """
      describe Fixnum do
        it "is available as described_class" do
          described_class.should == Fixnum
        end
      end
      """
    When I run "rspec spec/example_spec.rb"
    Then I should see "1 example, 0 failures"

