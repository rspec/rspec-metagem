module Rspec
  module Core
    module KernelExtensions

      def describe(*args, &behaviour_block)
        args << {} unless args.last.is_a?(Hash)
        args.last.update :caller => caller(1)
        Rspec::Core::ExampleGroup.describe(*args, &behaviour_block)
      end

      alias :context :describe

    end
  end
end

include Rspec::Core::KernelExtensions
