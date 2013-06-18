require "spec_helper"

module RSpec::Core::Ordering
  describe IdentityOrdering do
    it "does not affect the ordering of the items" do
      expect(IdentityOrdering.new.order([1, 2, 3])).to eq([1, 2, 3])
    end

    it 'is considered a built in ordering' do
      expect(IdentityOrdering.new).to be_built_in
    end
  end
end
