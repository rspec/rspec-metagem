Feature: aliasing
  `describe` and `context` are the default aliases for `example_group`.
  `describe` is defined at the top level, i.e. on Object. Context is only
  available from within an example group, i.e. within a describe block.
  You can describe your own aliases for `example_group` and give those
  custom aliases default meta data.

  Scenario: custom example group aliases with metadata
    Given a file named "nested_example_group_aliases_spec.rb" with:
    """ruby
    RSpec.configure do |c|
      c.alias_example_group_to :detail, { detailed: true }
    end

    describe "a thing" do
      describe "in broad strokes" do
        it "can do things" do
        end
      end

      detail "something less important" do
        it "can do an unimportant thing" do
        end
      end
    end
    """
    When I run `rspec nested_example_group_aliases_spec.rb --tag detailed -fdoc`
    Then the output should contain:
      """
      a thing
        something less important
      """

