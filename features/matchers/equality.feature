Feature: equality matchers

  RSpec equality comparison matchers.

  Typically, if you are comparing values, "eq" and "eql" will
  usually do the job. However, one thing to note is that "eq"
  will perform type conversion, while "eql" will not.

  If you need to compare equality of objects, "equal" is the
  one you want.

  Scenario: compare using eq (==)
    Given a file named "compare_using_eq.rb" with:
      """
      require 'spec_helper'

      describe "a string" do

        let(:string) { "foo" }

        it "is equal to another string of the same value" do
          string.should eq("foo")
        end

        it "is not equal to another string of a different value" do
          string.should_not eq("bar")
        end

      end

      describe "an integer" do

        let(:integer) { 5 }

        it "is equal to the same value in float type" do
          integer.should eq(5.0)
        end

      end
      """
    When I run "rspec compare_using_eq.rb"
    Then the output should contain "3 examples, 0 failures"

  Scenario: compare using eql (eql?)
    Given a file named "compare_using_eql.rb" with:
      """
      require 'spec_helper'

      describe "an integer" do

        let(:integer) { 5 }

        it "is equal to another integer of the same value" do
          integer.should eql(5)
        end

        it "is not equal to another integer of a different value" do
          integer.should_not eql(6)
        end

        it "is not equal to the same value in float type" do
          integer.should_not eql(5.0)
        end

      end
      """
    When I run "rspec compare_using_eql.rb"
    Then the output should contain "3 examples, 0 failures"

  Scenario: compare using equal (equal?)
    Given a file named "compare_using_equal.rb" with:
      """
      require 'spec_helper'

      describe "a string" do

        let(:string) { "foo" }

        it "is equal to itself" do
          string.should equal(string)
        end

        it "is not equal to another string of the same value" do
          string.should_not equal("foo")
        end

        it "is not equal to another string of a different value" do
          string.should_not equal("bar")
        end

      end
      """
    When I run "rspec compare_using_equal.rb"
    Then the output should contain "3 examples, 0 failures"

