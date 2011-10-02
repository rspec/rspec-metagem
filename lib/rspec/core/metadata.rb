module RSpec
  module Core
    class Metadata < Hash

      module MetadataHash
        def [](key)
          return super if has_key?(key)
          case key
          when :location
            store(:location, location)
          when :file_path, :line_number
            file_path, line_number = file_and_line_number
            store(:file_path, file_path)
            store(:line_number, line_number)
            self[key]
          when :execution_result
            store(:execution_result, {})
          when :describes
            store(:describes, described_class_for(self))
          when :full_description
            store(:full_description, full_description_for(self))
          when :description
            store(:description, build_description_from(*self[:description_args]))
          else
            super
          end
        end

        def location
          "#{self[:file_path]}:#{self[:line_number]}"
        end

        def file_and_line_number
          first_caller_from_outside_rspec =~ /(.+?):(\d+)(|:\d+)/
          return [$1, $2.to_i]
        end

        def first_caller_from_outside_rspec
          self[:caller].detect {|l| l !~ /\/lib\/rspec\/core/}
        end

        def described_class_for(m)
          while m.has_key?(:example_group)
            return m[:example_group][:describes] if m[:example_group].has_key?(:describes)
            m = m[:example_group]
          end
          candidate = m[:description_args].first
          String === candidate || Symbol === candidate ? nil : candidate
        end

        def full_description_for(m)
          parts = [m[:description_args]]
          while m.has_key?(:example_group)
            m = m[:example_group]
            parts.unshift m[:description_args]
          end
          build_description_from(*parts.flatten)
        end

        def build_description_from(*parts)
          parts.map {|p| p.to_s}.reduce do |desc, p|
            p =~ /^(#|::|\.)/ ? "#{desc}#{p}" : "#{desc} #{p}"
          end || ""
        end
      end

      def initialize(parent_group_metadata=nil)
        if parent_group_metadata
          update(parent_group_metadata)
          store(:example_group, {:example_group => parent_group_metadata[:example_group]}.extend(MetadataHash))
        else
          store(:example_group, {}.extend(MetadataHash))
        end

        yield self if block_given?
      end

      RESERVED_KEYS = [
        :description,
        :example_group,
        :execution_result,
        :file_path,
        :full_description,
        :line_number,
        :location
      ]

      def process(*args)
        user_metadata = args.last.is_a?(Hash) ? args.pop : {}
        ensure_valid_keys(user_metadata)

        self[:example_group].store(:description_args, args)
        self[:example_group].store(:caller, user_metadata.delete(:caller) || caller)

        update(user_metadata)
      end

      def ensure_valid_keys(user_metadata)
        RESERVED_KEYS.each do |key|
          if user_metadata.keys.include?(key)
            raise <<-EOM
#{"*"*50}
:#{key} is not allowed

RSpec reserves some hash keys for its own internal use,
including :#{key}, which is used on:

  #{caller(0)[4]}.

Here are all of RSpec's reserved hash keys:

  #{RESERVED_KEYS.join("\n  ")}
#{"*"*50}
EOM
            raise ":#{key} is not allowed"
          end
        end
      end

      def for_example(description, user_metadata)
        dup.extend(MetadataHash).configure_for_example(description, user_metadata)
      end

      def configure_for_example(description, user_metadata)
        store(:description_args, [description])
        store(:caller, user_metadata.delete(:caller) || caller)
        update(user_metadata)
      end

      def any_apply?(filters)
        filters.any? {|k,v| filter_applies?(k,v)}
      end

      def all_apply?(filters)
        filters.all? {|k,v| filter_applies?(k,v)}
      end

      def relevant_line_numbers(metadata)
        line_numbers = [metadata[:line_number]]
        if metadata[:example_group]
          line_numbers + relevant_line_numbers(metadata[:example_group])
        else
          line_numbers
        end
      end

      def filter_applies?(key, value, metadata=self)
        case value
        when Hash
          if key == :locations
            file_path     = (self[:example_group] || {})[:file_path]
            expanded_path = file_path && File.expand_path( file_path )
            if expanded_path && line_numbers = value[expanded_path]
              self.filter_applies?(:line_numbers, line_numbers)
            else
              true
            end
          else
            value.all? { |k, v| filter_applies?(k, v, metadata[key]) }
          end
        when Regexp
          metadata[key] =~ value
        when Proc
          if value.arity == 2
            # Pass the metadata hash to allow the proc to check if it even has the key.
            # This is necessary for the implicit :if exclusion filter:
            #   {            } # => run the example
            #   { :if => nil } # => exclude the example
            # The value of metadata[:if] is the same in these two cases but
            # they need to be treated differently.
            value.call(metadata[key], metadata) rescue false
          else
            value.call(metadata[key]) rescue false
          end
        when String
          metadata[key].to_s == value.to_s
        when Enumerable
          if key == :line_numbers
            preceding_declaration_lines = value.map{|v| world.preceding_declaration_line(v)}
            !(relevant_line_numbers(metadata) & preceding_declaration_lines).empty?
          else
            metadata[key] == value
          end
        else
          metadata[key].to_s == value.to_s
        end
      end

    private

      def world
        RSpec.world
      end

    end
  end
end
