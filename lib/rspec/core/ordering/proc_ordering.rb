module RSpec::Core::Ordering
  class ProcOrdering
    def initialize(configuration=RSpec.configuration, &block)
      @block = block
    end

    def order(list)
      @block.call(list)
    end

    def built_in?
      false
    end
  end
end
