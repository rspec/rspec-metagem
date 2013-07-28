module RSpec::Core::Ordering
  class RandomOrdering
    def order(items, configuration = RSpec.configuration)
      Kernel.srand configuration.seed
      ordering = items.shuffle
      Kernel.srand # reset random generation
      ordering
    end

    def built_in?
      true
    end
  end
end
