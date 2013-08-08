require 'spec_helper'

module RSpec
  module Core
    RSpec.describe RandomNumberGenerator do
      it 'is a random number generator' do
        random = described_class.new

        expect([Fixnum, Bignum]).to include random.seed.class
        expect(random.rand).to be_a Float

        rands = []
        100.times do
          rands << random.rand
        end

        expect(rands.uniq.count).to be > 90
      end

      it 'produces the same results given the same seed' do
        seed = rand(999)

        random = described_class.new(seed)

        expect(random.seed).to eq seed

        expected = []
        5.times do
          expected << random.rand(999)
        end

        10.times do
          random = described_class.new(seed)

          expect(random.seed).to eq seed

          actual = []
          5.times do
            actual << random.rand(999)
          end

          expect(actual).to eq expected
        end
      end
    end
  end
end
