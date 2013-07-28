module RSpec::Core::Ordering
  class IdentityOrdering
    def order(items, configuration = RSpec.configuration)
      items
    end

    def built_in?
      true
    end
  end
end
