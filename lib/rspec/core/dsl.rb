module RSpec
  module Core
    # Adds the `describe` method to the top-level namespace.
    module DSL
      # Generates a subclass of [ExampleGroup](ExampleGroup)
      #
      # ## Examples:
      #
      #     describe "something" do
      #       it "does something" do
      #         # example code goes here
      #       end
      #     end
      #
      # @see ExampleGroup
      # @see ExampleGroup.describe
      def describe(*args, &example_group_block)
        RSpec::Core::ExampleGroup.describe(*args, &example_group_block).register
      end
    end
  end
end

include RSpec::Core::DSL
