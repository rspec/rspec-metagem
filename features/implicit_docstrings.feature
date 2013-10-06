Feature: implicit docstrings

  As an RSpec user
  I want examples to generate their own names
  So that I can reduce duplication between example names and example code

  Scenario: run passing examples
    Given a file named "implicit_docstrings_spec.rb" with:
    """ruby
    describe "Examples with no docstrings generate their own:" do

      specify { expect(3).to be < 5 }

      specify { expect([1,2,3]).to include(2) }

      specify { expect([1,2,3]).to respond_to(:size) }

    end
    """

    When I run `rspec ./implicit_docstrings_spec.rb -fdoc`

    Then the output should contain "should be < 5"
    And the output should contain "should include 2"
    And the output should contain "should respond to #size"

  Scenario: run failing examples
    Given a file named "failing_implicit_docstrings_spec.rb" with:
    """ruby
    describe "Failing examples with no descriptions" do

      # description is auto-generated as "to equal(5)" based on the last #expect
      it do
        expect(3).to equal(2)
        expect(5).to equal(5)
      end

      it { expect(3).to be > 5 }

      it { expect([1,2,3]).to include(4) }

      it { expect([1,2,3]).not_to respond_to(:size) }

    end
    """

    When I run `rspec ./failing_implicit_docstrings_spec.rb -fdoc`

    Then the output should contain "should equal 2"
    And the output should contain "should be > 5"
    And the output should contain "should include 4"
    And the output should contain "should not respond to #size"
