module Rspec
  module Core
    module KernelExtensions

      def describe(*args, &example_group_block)
        args << {} unless args.last.is_a?(Hash)
        args.last.update :caller => caller(1)
        Rspec::Core::ExampleGroup.describe(*args, &example_group_block)
      end

      alias :context :describe

    end
  end
end

include Rspec::Core::KernelExtensions
