module RSpec
  module Core
    class AroundProxy
      def initialize(example_group_instance, &example_block)
        @example_group_instance, @example_block = example_group_instance, example_block
      end

      def run
        @example_group_instance.instance_eval(&@example_block)
      end
    end
  end
end

