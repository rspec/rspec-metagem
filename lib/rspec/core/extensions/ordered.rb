module RSpec
  module Core
    module Extensions
      module Ordered
        def ordered
          if RSpec.configuration.randomize?
            srand RSpec.configuration.seed if RSpec.configuration.seed
            sort_by { rand size }
          else
            self
          end
        end
      end
    end
  end
end
