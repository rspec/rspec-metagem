module RSpec
  module Core
    module Extensions
      # Extends lists of example groups and examples to support ordering
      # strategies like randomization.
      module Ordered
        def ordered
          if RSpec.configuration.randomize?
            srand RSpec.configuration.seed
            sort_by { rand size }
          else
            self
          end
        end
      end
    end
  end
end
