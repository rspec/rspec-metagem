module RSpec
  module Core
    module Bisect
      # Enumerates each subset of the given list of ids that is half the
      # size of the total list, so that hopefully we can discard half the
      # list each repeatedly in order to our minimal repro case.
      # @private
      class SubsetEnumerator
        include Enumerable

        def initialize(ids)
          @ids = ids
        end

        def subset_size
          @subset_size ||= (@ids.size / 2.0).ceil
        end

        def each
          yielded     = Set.new
          slice_size  = subset_size
          combo_count = 1

          while slice_size > 0
            @ids.each_slice(slice_size).to_a.combination(combo_count) do |combos|
              subset = combos.flatten
              next if yielded.include?(subset)
              yield subset
              yielded << subset
            end

            slice_size  /= 2
            combo_count *= 2
          end
        end
      end
    end
  end
end
