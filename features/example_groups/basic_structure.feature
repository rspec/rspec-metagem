Feature: basic structure (describe/it)

  RSpec is a DSL for creating executable examples of how code is expected to
  behave, organized in groups. It uses the words "describe" and "it" so we can
  express concepts like a conversation:

    "Describe an account when it is first opened."
    "It has a balance of zero."

  The describe() method creates a subclass of RSpec::Core::ExampleGroup. The
  block passed to describe() is evaluated in the context of that class, so any
  class methods of ExampleGroup are at your disposal within that block.

  Within a group, you can declare nested groups using the describe() or
  context() methods. A nested group is actually a subclass of the outer group,
  so it has access to same methods as the outer group, as well as any class
  methods defined in the outer group.

  The it() method accepts a block, which is later executed in the context of
  an instance of the group in which it is declared.

  Scenario: one group, one example
    Given a file named "sample_spec.rb" with:
    """
    describe "something" do
      it "does something" do
      end
    end
    """
    When I run "rspec sample_spec.rb -fn"
    Then the output should contain:
      """
      something
        does something
      """

  Scenario: nested example groups (using context)
    Given a file named "nested_example_groups_spec.rb" with:
    """
    describe "something" do
      context "in one context" do
        it "does one thing" do
        end
      end
      context "in another context" do
        it "does another thing" do
        end
      end
    end
    """
    When I run "rspec nested_example_groups_spec.rb -fdoc"
    Then the output should contain:
      """
      something
        in one context
          does one thing
        in another context
          does another thing
      """
