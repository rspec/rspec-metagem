Feature: implicit subject

  The first argument to the outermost example group block is
  made available to each example as an implicit subject of
  that example.

  Scenario: subject in top level group
    Given a file named "top_level_subject_spec.rb" with:
      """
      describe Array, "when first created" do
        it "should be empty" do
          subject.should == []
        end
      end
      """
    When I run "rspec ./top_level_subject_spec.rb"
    Then the output should contain "1 example, 0 failures"

  Scenario: subject in a nested group
    Given a file named "nested_subject_spec.rb" with:
      """
      describe Array do
        describe "when first created" do
          it "should be empty" do
            subject.should == []
          end
        end
      end
      """
    When I run "rspec ./nested_subject_spec.rb"
    Then the output should contain "1 example, 0 failures"
