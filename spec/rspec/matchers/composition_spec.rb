require 'spec_helper'

module RSpec::Matchers::BuiltIn

  describe "chain matchers with #and" do

    it_behaves_like "an RSpec matcher",
      :valid_value => 3,
      :invalid_value => 4 do
      let(:matcher) { eq(3).and( be <= 3 ) }
      end

    describe "expect(obj).to matcher.and(other_matcher)" do

      it "passes if both assertions pass" do
        expect(3).to eq(3).and( be >= 2 )
      end

      it "fails if the first matcher fail" do
        expect {
          expect(3).to eq(4).and( be >= 2 )
        }.to fail_with(/expected: 4.*got: 3/m)
      end

      it "fails if the second matcher fail" do
        expect {
          expect(3).to  (be >= 2).and( eq(4) )
        }.to fail_with(/expected: 4.*got: 3/m)
      end

      it "fails if both matcher fails" do
        expect {
          expect(3).to eq(4).and( be >= 8 )
        }.to fail_with(/expected: 4.*got: 3/m)
      end

    end

  end
end
