module RSpec::Core::Ordering
  class CustomOrdering
    def initialize(callable)
      @callable = callable
    end

    def order(list, configuration = RSpec.configuration)
      @callable.call(list)
    end

    def built_in?
      false
    end
  end
end
