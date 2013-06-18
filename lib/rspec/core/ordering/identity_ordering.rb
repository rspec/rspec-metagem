module RSpec::Core::Ordering
  class IdentityOrdering
    def initialize(configuration=RSpec.configuration)
    end

    def order(items)
      items
    end

    def built_in?
      true
    end
  end
end
