module Spec
  module Core
    module KernelExtensions

      def describe(*args, &behaviour_block)
        Spec::Core::Behaviour.describe(*args, &behaviour_block)
      end

    end
  end
end

include Spec::Core::KernelExtensions