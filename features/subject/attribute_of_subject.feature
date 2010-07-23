Feature: attribute of subject

  Scenario: simple attribute
    Given a file named "example_spec.rb" with:
      """
      describe Array do
        its(:size) { should == 0 }
      end
      """
    When I run "rspec example_spec.rb --format documentation"
    Then the output should contain:
      """
      Array
        size
          should == 0
      """

  Scenario: nested attribute
    Given a file named "example_spec.rb" with:
      """
      class Person
        attr_reader :phone_numbers
        def initialize
          @phone_numbers = []
        end
      end

      describe Person do
        subject do
          person = Person.new
          person.phone_numbers << "555-1212"
          person
        end

        its("phone_numbers.first") { should == "555-1212" }
      end
      """
    When I run "rspec example_spec.rb --format documentation"
    Then the output should contain:
      """
      Person
        phone_numbers.first
          should == "555-1212"
      """
