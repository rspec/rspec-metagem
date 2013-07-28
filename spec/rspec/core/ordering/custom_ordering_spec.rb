require 'spec_helper'

module RSpec::Core::Ordering
  describe CustomOrdering do
    it 'uses the block to order the list' do
      strategy = CustomOrdering.new(proc { |list| list.reverse })

      expect(strategy.order([1, 2, 3, 4])).to eq([4, 3, 2, 1])
    end

    it 'is not considered a built in ordering' do
      expect(CustomOrdering.new(proc { })).not_to be_built_in
    end
  end
end
