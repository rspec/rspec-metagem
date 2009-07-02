module Rspec
  module Core
    module KernelExtensions

      def describe(*args, &behaviour_block)
        Rspec::Core::ExampleGroup.describe(*args, &behaviour_block)
      end
      
      alias :context :describe

    end
  end
end

include Rspec::Core::KernelExtensions
