module RSpec
  module Core
    # Contains metadata filtering logic. This has been extracted from
    # the metadata classes because it operates ON a metadata hash but
    # does not manage any of the state in the hash. We're moving towards
    # having metadata be a raw hash (not a custom subclass), so externalizing
    # this filtering logic helps us move in that direction.
    module MetadataFilter
      class << self
        # @private
        def apply?(predicate, filters, metadata)
          filters.__send__(predicate) { |k, v| filter_applies?(k, v, metadata) }
        end

        # @private
        def filter_applies?(key, value, metadata)
          silence_metadata_example_group_deprecations do
            return filter_applies_to_any_value?(key, value, metadata) if Array === metadata[key] && !(Proc === value)
            return location_filter_applies?(value, metadata)          if key == :locations
            return filters_apply?(key, value, metadata)               if Hash === value

            return false unless metadata.key?(key)

            case value
            when Regexp
              metadata[key] =~ value
            when Proc
              case value.arity
              when 0 then value.call
              when 2 then value.call(metadata[key], metadata)
              else value.call(metadata[key])
              end
            else
              metadata[key].to_s == value.to_s
            end
          end
        end

      private

        def filter_applies_to_any_value?(key, value, metadata)
          metadata[key].any? { |v| filter_applies?(key, v,  key => value) }
        end

        def location_filter_applies?(locations, metadata)
          # it ignores location filters for other files
          line_number = example_group_declaration_line(locations, metadata)
          line_number ? line_number_filter_applies?(line_number, metadata) : true
        end

        def line_number_filter_applies?(line_numbers, metadata)
          preceding_declaration_lines = line_numbers.map { |n| RSpec.world.preceding_declaration_line(n) }
          !(relevant_line_numbers(metadata) & preceding_declaration_lines).empty?
        end

        def relevant_line_numbers(metadata)
          return [] unless metadata
          [metadata[:line_number]].compact + (relevant_line_numbers(parent_of metadata))
        end

        def example_group_declaration_line(locations, metadata)
          parent = parent_of(metadata)
          return nil unless parent
          locations[File.expand_path(parent[:file_path])]
        end

        def filters_apply?(key, value, metadata)
          subhash = metadata[key]
          return false unless Hash === subhash || HashImitatable === subhash
          value.all? { |k, v| filter_applies?(k, v, subhash) }
        end

        def parent_of(metadata)
          if metadata.key?(:example_group)
            metadata[:example_group]
          else
            metadata[:parent_example_group]
          end
        end

        def silence_metadata_example_group_deprecations
          RSpec.thread_local_metadata[:silence_metadata_example_group_deprecations] = true
          yield
        ensure
          RSpec.thread_local_metadata.delete(:silence_metadata_example_group_deprecations)
        end
      end
    end

    # Tracks a collection of filterable items (e.g. modules, hooks, etc)
    # and provides an optimized API to get the applicable items for the
    # metadata of an example or example group.
    # @private
    class FilterableItemRepository
      attr_reader :items_and_filters

      def initialize(applies_predicate)
        @applies_predicate = applies_predicate
        @items_and_filters = []
        @applicable_keys   = Set.new
        @proc_keys         = Set.new
        @memoized_lookups  = Hash.new do |hash, applicable_metadata|
          hash[applicable_metadata] = find_items_for(applicable_metadata)
        end
      end

      def append(item, metadata)
        @items_and_filters << [item, metadata]
        handle_mutation(metadata)
      end

      def prepend(item, metadata)
        @items_and_filters.unshift [item, metadata]
        handle_mutation(metadata)
      end

      def items_for(metadata)
        # The filtering of `metadata` to `applicable_metadata` is the key thing
        # that makes the memoization actually useful in practice, since each
        # example and example group have different metadata (e.g. location and
        # description). By filtering to the metadata keys our items care about,
        # we can ignore extra metadata keys that differ for each example/group.
        # For example, given `config.include DBHelpers, :db`, example groups
        # can be split into these two sets: those that are tagged with `:db` and those
        # that are not. For each set, this method for the first group in the set is
        # still an `O(N)` calculation, but all subsequent groups in the set will be
        # constant time lookups when they call this method.
        applicable_metadata = applicable_metadata_from(metadata)

        if applicable_metadata.keys.any? { |k| @proc_keys.include?(k) }
          # It's unsafe to memoize lookups involving procs (since they can
          # be non-deterministic), so we skip the memoization in this case.
          find_items_for(applicable_metadata)
        else
          @memoized_lookups[applicable_metadata]
        end
      end

    private

      def handle_mutation(metadata)
        @applicable_keys.merge(metadata.keys)
        @proc_keys.merge(proc_keys_from metadata)
        @memoized_lookups.clear
      end

      def applicable_metadata_from(metadata)
        metadata.select do |key, _value|
          @applicable_keys.include?(key)
        end
      end

      def find_items_for(request_meta)
        @items_and_filters.each_with_object([]) do |(item, item_meta), to_return|
          to_return << item if item_meta.empty? ||
                               MetadataFilter.apply?(@applies_predicate, item_meta, request_meta)
        end
      end

      def proc_keys_from(metadata)
        metadata.each_with_object([]) do |(key, value), to_return|
          to_return << key if Proc === value
        end
      end

      if {}.select {} == [] # For 1.8.7
        undef applicable_metadata_from
        def applicable_metadata_from(metadata)
          Hash[metadata.select do |key, _value|
            @applicable_keys.include?(key)
          end]
        end
      end

      unless [].respond_to?(:each_with_object) # For 1.8.7
        undef find_items_for
        def find_items_for(request_meta)
          @items_and_filters.inject([]) do |to_return, (item, item_meta)|
            to_return << item if item_meta.empty? ||
                                 MetadataFilter.apply?(@applies_predicate, item_meta, request_meta)
            to_return
          end
        end

        undef proc_keys_from
        def proc_keys_from(metadata)
          metadata.inject([]) do |to_return, (key, value)|
            to_return << key if Proc === value
            to_return
          end
        end
      end
    end
  end
end
