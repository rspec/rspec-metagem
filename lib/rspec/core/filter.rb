module RSpec
  module Core
    class Filter
      attr_reader :exclusions, :inclusions

      def initialize
        @exclusions = {}
        @inclusions = {}
      end

      def filter(examples)
        examples.select {|e| !exclude?(e) && include?(e)}
      end

      def exclude?(example)
        @exclusions.empty? ? false : example.any_apply?(@exclusions)
      end

      def include?(example)
        @inclusions.empty? ? true : example.any_apply?(@inclusions)
      end

      def exclude(*args)
        @exclusions = update(@exclusions, *args)
      end

      def include(*args)
        @inclusions = update(@inclusions, *args)
      end

      def update(orig, *updates)
        updates.length == 2 ? updates.last.merge(orig) : orig.merge(updates.last)
      end
    end
  end
end
