Feature: Helper methods

  Helper methods defined in an example group can be used in any examples in
  that group or any subgroups.  Examples in parent or sibling example groups
  will not have access.

  Scenario: Helper methods can be accessed from examples in group and subgroups
    Given a file named "helper_method_spec.rb" with:
      """
      describe "helper methods" do
        def my_helper
          "foo"
        end

        it "has access to the helper method" do
          my_helper.should == "foo"
        end

        describe "a subgroup" do
          it "also has access to the helper method" do
            my_helper.should == "foo"
          end
        end
      end
      """
    When I run "rspec helper_method_spec.rb"
    Then the output should contain "2 examples, 0 failures"

  Scenario: Helper methods cannot be accessed from examples in parent or sibling groups
    Given a file named "helper_methods_spec.rb" with:
      """
      describe "helper methods" do
        describe "subgroup 1" do
          def my_helper
            "foo"
          end
        end

        it "does not have access in the parent group" do
          expect { my_helper }.to raise_error(/undefined local variable or method `my_helper'/)
        end

        describe "subgroup 2" do
          it "does not have access in a sibling group" do
            expect { my_helper }.to raise_error(/undefined local variable or method `my_helper'/)
          end
        end
      end
      """
    When I run "rspec helper_methods_spec.rb"
    Then the output should contain "2 examples, 0 failures"

