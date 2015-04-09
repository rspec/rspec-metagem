require 'rspec/core/bisect/subset_enumerator'

module RSpec::Core
  RSpec.describe Bisect::SubsetEnumerator do
    def enum_for(ids)
      Bisect::SubsetEnumerator.new(ids)
    end

    it 'is enumerable' do
      expect(enum_for([])).to be_an(Enumerable)
    end

    it 'systematically enumerates each subset of the given size, starting off with disjoint sets' do
      ids = %w[ 1 2 3 4 5 6 7 8 ]
      enum = enum_for(ids)
      combos = enum.to_a
      expect(combos).to start_with([
        # start with each half...
        %w[ 1 2 3 4 ], %w[ 5 6 7 8 ],
        # then cut in 4ths and combine those in all the unseen combos...
        %w[ 1 2 5 6 ], %w[ 1 2 7 8 ],
        %w[ 3 4 5 6 ], %w[ 3 4 7 8 ],
        # then cut in 8ths and do the same...
        %w[ 1 2 3 5 ], %w[ 1 2 3 6 ], %w[ 1 2 3 7 ], %w[ 1 2 3 8 ],
        %w[ 1 2 4 5 ], %w[ 1 2 4 6 ], %w[ 1 2 4 7 ], %w[ 1 2 4 8 ]
      ])

      # We don't care to specify the rest of the order, but we care that all combos were hit.
      expect(combos).to match_array(ids.combination(4))
    end

    it 'works with a list size that is not a power of 2' do
      ids = %w[ 1 2 3 4 5 6 7 ]
      enum = enum_for(ids)
      combos = enum.to_a
      expect(combos).to start_with([
        %w[ 1 2 3 4 ], %w[ 5 6 7 ],
        %w[ 1 2 5 6 ], %w[ 1 2 7 ],
        %w[ 3 4 5 6 ], %w[ 3 4 7 ]
      ])

      # Would be better to do: expect(combos).to match_array(ids.combination(4))
      # ...but we include a few extra sets of 3 due to our algorithm.
      expect(combos).to include(*ids.combination(4))
    end
  end
end
