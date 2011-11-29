module RSpec
  module Core
    module Extensions
      # Extends lists of example groups and examples to support ordering
      # strategies like randomization.
      module Ordered
        def ordered
          if RSpec.configuration.randomize?
            Kernel.srand RSpec.configuration.seed
            sort_by { Kernel.rand size }
          else
            self
          end
        end
      end
    end
  end
end
