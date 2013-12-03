module RSpec

  # Defines a named context for one or more examples. The given block
  # is evaluated in the context of a generated subclass of
  # {RSpec::Core::ExampleGroup}
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
  def self.describe(*args, &example_group_block)
    RSpec::Core::ExampleGroup.describe(*args, &example_group_block).register
  end

  module Core
    module DSL

      class << self
        # @private
        attr_accessor :top_level
      end

      # @private
      def self.exposed_globally?
        @exposed_globally ||= false
      end

      # Add's the describe method to Module and the top level binding
      def self.expose_globally!
        return if exposed_globally?

        to_define = proc do
          def describe(*args, &block)
            ::RSpec.describe(*args, &block)
          end
        end

        top_level.instance_eval(&to_define)
        Module.class_exec(&to_define)
        @exposed_globally = true
      end

      def self.remove_globally!
        return unless exposed_globally?

        to_undefine = proc do
          undef describe
        end

        top_level.instance_eval(&to_undefine)
        Module.class_exec(&to_undefine)
        @exposed_globally = false
      end

    end
  end
end

# cature main without an eval
::RSpec::Core::DSL.top_level = self
