Feature: let

  RSpec provides the `let` macro for defining a memoized helper method.
  The value will be cached across multiple calls in the same example but not
  across examples.  You can use `let!` to cause the method to be called in a
  `before(:each)` hook.

  Scenario: Use let to define memoized helper method
    Given a file named "let_spec.rb" with:
      """
      $count = 0
      describe "let" do
        let(:count) { $count += 1 }

        it "memoizes the value" do
          count.should == 1
          count.should == 1
        end

        it "is not cached across examples" do
          count.should == 2
        end
      end
      """
    When I run "rspec let_spec.rb"
    Then the output should contain "2 examples, 0 failures"

  Scenario: Use let! to define a memoized helper method that is called in a before hook
    Given a file named "let_bang_spec.rb" with:
      """
      $count = 0
      describe "let!" do
        invocation_order = []

        let!(:count) do
          invocation_order << :let!
          $count += 1
        end

        it "calls the helper method in a before hook" do
          invocation_order << :example
          invocation_order.should == [:let!, :example]
          count.should == 1
        end
      end
      """
    When I run "rspec let_bang_spec.rb"
    Then the output should contain "1 example, 0 failures"
