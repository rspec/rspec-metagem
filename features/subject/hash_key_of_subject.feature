Feature: hash key of subject

  its() accepts an array with a single item, which will be used as a key if the
  subject is a hash. Regular attribute matchers still work the same.

  Scenario: simple attribute
    Given a file named "example_spec.rb" with:
      """
      describe Hash do
        subject do
          {:one => 'one', :two => 'two'}
        end
        
        its(:size) { should == 2 }
      end
      """
    When I run "rspec example_spec.rb --format documentation"
    Then the output should contain "1 example, 0 failures"

  Scenario: hash keys
    Given a file named "example_spec.rb" with:
      """
      describe Hash do
        subject do
          {:one => 'one', "two" => 'two'}
        end

        its([:one]) { should == 'one' }
        its(["two"]) { should == 'two' }
      end
      """
    When I run "rspec example_spec.rb --format documentation"
    Then the output should contain "2 examples, 0 failures"
