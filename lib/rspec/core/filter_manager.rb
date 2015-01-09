module RSpec
  module Core
    # @private
    class FilterManager
      attr_reader :exclusions, :inclusions

      def initialize
        @exclusions, @inclusions = FilterRules.build
      end

      # @api private
      #
      # @param file_path [String]
      # @param line_numbers [Array]
      def add_location(file_path, line_numbers)
        # locations is a hash of expanded paths to arrays of line
        # numbers to match against. e.g.
        #   { "path/to/file.rb" => [37, 42] }
        locations = inclusions.delete(:locations) || Hash.new { |h, k| h[k] = [] }
        locations[File.expand_path(file_path)].push(*line_numbers)
        inclusions.add_location(locations)
      end

      def empty?
        inclusions.empty? && exclusions.empty?
      end

      def prune(examples)
        if inclusions.standalone?
          base_exclusions = ExclusionRules.new
          examples.select { |e| !base_exclusions.include_example?(e) && include?(e) }
        else
          examples.select { |e| !exclude?(e) && include?(e) }
        end
      end

      def exclude(*args)
        exclusions.add(args.last)
      end

      def exclude_only(*args)
        exclusions.use_only(args.last)
      end

      def exclude_with_low_priority(*args)
        exclusions.add_with_low_priority(args.last)
      end

      def exclude?(example)
        exclusions.include_example?(example)
      end

      def include(*args)
        inclusions.add(args.last)
      end

      def include_only(*args)
        inclusions.use_only(args.last)
      end

      def include_with_low_priority(*args)
        inclusions.add_with_low_priority(args.last)
      end

      def include?(example)
        inclusions.include_example?(example)
      end
    end

    # @private
    class FilterRules
      PROC_HEX_NUMBER = /0x[0-9a-f]+@/
      PROJECT_DIR = File.expand_path('.')

      attr_accessor :opposite
      attr_reader :rules

      def self.build
        exclusions = ExclusionRules.new
        inclusions = InclusionRules.new
        exclusions.opposite = inclusions
        inclusions.opposite = exclusions
        [exclusions, inclusions]
      end

      def initialize(*args, &block)
        @rules = Hash.new(*args, &block)
      end

      def add(updated)
        @rules.merge!(updated).each_key { |k| opposite.delete(k) }
      end

      def add_with_low_priority(updated)
        updated = updated.merge(@rules)
        opposite.each_pair { |k, v| updated.delete(k) if updated[k] == v }
        @rules.replace(updated)
      end

      def use_only(updated)
        updated.each_key { |k| opposite.delete(k) }
        @rules.replace(updated)
      end

      def clear
        @rules.clear
      end

      def delete(key)
        @rules.delete(key)
      end

      def fetch(*args, &block)
        @rules.fetch(*args, &block)
      end

      def [](key)
        @rules[key]
      end

      def empty?
        rules.empty?
      end

      def each_pair(&block)
        @rules.each_pair(&block)
      end

      def description
        rules.inspect.gsub(PROC_HEX_NUMBER, '').gsub(PROJECT_DIR, '.').gsub(' (lambda)', '')
      end
    end

    # @private
    class InclusionRules < FilterRules
      STANDALONE_FILTERS = [:locations, :full_description]

      def add_location(locations)
        replace_filters(:locations => locations)
      end

      def add(*args)
        apply_standalone_filter(*args) || super
      end

      def add_with_low_priority(*args)
        apply_standalone_filter(*args) || super
      end

      def use(*args)
        apply_standalone_filter(*args) || super
      end

      def include_example?(example)
        return true if @rules.empty?
        MetadataFilter.apply?(:any?, @rules, example.metadata)
      end

      def standalone?
        is_standalone_filter?(@rules)
      end

    private

      def apply_standalone_filter(updated)
        return true if standalone?
        return nil unless is_standalone_filter?(updated)

        replace_filters(updated)
        true
      end

      def replace_filters(new_rules)
        @rules.replace(new_rules)
        opposite.clear
      end

      def is_standalone_filter?(rules)
        STANDALONE_FILTERS.any? { |key| rules.key?(key) }
      end
    end

    # @private
    class ExclusionRules < FilterRules
      CONDITIONAL_FILTERS = {
        :if     => lambda { |value| !value },
        :unless => lambda { |value| value }
      }.freeze

      def include_example?(example)
        example_meta = example.metadata
        return true if MetadataFilter.apply?(:any?, @rules, example_meta)
        MetadataFilter.apply?(:any?, CONDITIONAL_FILTERS, example_meta)
      end
    end
  end
end
