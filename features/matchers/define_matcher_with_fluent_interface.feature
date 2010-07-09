Feature: define matcher

  In order to express my domain clearly in my code examples
  As an RSpec user
  I want to define matchers with fluent interfaces
  
  Scenario: one additional method
    Given a file named "between_spec.rb" with:
      """
      RSpec::Matchers.define :be_bigger_than do |first|
        def but_smaller_than(second)
          @second = second
          self
        end
        
        match do |actual|
          (actual > first) && (actual < @second)
        end
      end

      describe 5 do
        it { should be_bigger_than(4).but_smaller_than(6) }
      end
      """
    When I run "rspec ./between_spec.rb --format documentation"
    Then the output should contain "1 example, 0 failures"
    And  the output should contain "should be bigger than 4"
