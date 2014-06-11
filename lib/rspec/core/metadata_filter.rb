module RSpec
  module Core
    # Contains metadata filtering logic. This has been extracted from
    # the metadata classes because it operates ON a metadata hash but
    # does not manage any of the state in the hash. We're moving towards
    # having metadata be a raw hash (not a custom subclass), so externalizing
    # this filtering logic helps us move in that direction.
    module MetadataFilter
      extend self

      # @private
      def any_apply?(filters, metadata)
        filters.any? { |k, v| filter_applies?(k, v, metadata) }
      end

      # @private
      def all_apply?(filters, metadata)
        filters.all? { |k, v| filter_applies?(k, v, metadata) }
      end

      # @private
      def filter_applies?(key, value, metadata)
        silence_metadata_example_group_deprecations do
          return filter_applies_to_any_value?(key, value, metadata) if Array === metadata[key] && !(Proc === value)
          return location_filter_applies?(value, metadata)          if key == :locations
          return filters_apply?(key, value, metadata)               if Hash === value

          return false unless metadata.has_key?(key)

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
        metadata[key].any? {|v| filter_applies?(key, v, {key => value})}
      end

      def location_filter_applies?(locations, metadata)
        # it ignores location filters for other files
        line_number = example_group_declaration_line(locations, metadata)
        line_number ? line_number_filter_applies?(line_number, metadata) : true
      end

      def line_number_filter_applies?(line_numbers, metadata)
        preceding_declaration_lines = line_numbers.map {|n| RSpec.world.preceding_declaration_line(n)}
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
end
