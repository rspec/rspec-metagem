module Rspec
  module Core
    class Metadata < Hash

      def self.process(superclass_metadata, *args)
        new(superclass_metadata) do |metadata|
          metadata.process(*args)
        end
      end
      
      attr_reader :superclass_metadata

      def initialize(superclass_metadata=nil)
        @superclass_metadata = superclass_metadata
        update(@superclass_metadata) if @superclass_metadata
        store(:example_group, {})
        store(:behaviour, self[:example_group])
        yield self if block_given?
      end

      def process(*args)
        extra_metadata = args.last.is_a?(Hash) ? args.pop : {}
        extra_metadata.delete(:example_group) # Remove it when present to prevent it clobbering the one we setup
        extra_metadata.delete(:behaviour)     # Remove it when present to prevent it clobbering the one we setup

        self[:example_group][:describes] = described_class_from(args)
        self[:example_group][:description] = description_from(args)
        self[:example_group][:full_description] = full_description_from(args)

        self[:example_group][:block] = extra_metadata.delete(:example_group_block)
        self[:example_group][:caller] = extra_metadata.delete(:caller) || caller(1)
        self[:example_group][:file_path] = file_path_from(self[:example_group], extra_metadata.delete(:file_path))
        self[:example_group][:line_number] = line_number_from(self[:example_group], extra_metadata.delete(:line_number))
        self[:example_group][:location] = location_from(self[:example_group])

        update(extra_metadata)
      end

      def for_example(description, options)
        dup.configure_for_example(description,options)
      end

      def configure_for_example(description, options)
        store(:description, description.to_s)
        store(:full_description, "#{self[:example_group][:full_description]} #{self[:description]}")
        store(:execution_result, {})
        store(:caller, options.delete(:caller))
        if self[:caller]
          store(:file_path, file_path_from(self))
          store(:line_number, line_number_from(self))
        end
        self[:location] = location_from(self)
        update(options)
      end

      def apply_condition(filter_on, filter, metadata=nil)
        metadata ||= self
        case filter
        when Hash
          filter.all? { |k, v| apply_condition(k, v, metadata[filter_on]) }
        when Regexp
          metadata[filter_on] =~ filter
        when Proc
          filter.call(metadata[filter_on]) rescue false
        when Fixnum
          if filter_on == :line_number
            [metadata[:line_number],metadata[:example_group][:line_number]].include?(filter)
          else
            metadata[filter_on] == filter
          end
        else
          metadata[filter_on] == filter
        end
      end

      def all_apply?(filters)
        filters.all? do |filter_on, filter|
          apply_condition(filter_on, filter)
        end
      end

    private

      def description_from(args)
        @build_description ||= args.map{|a| a.to_s.strip}.join(" ")
      end

      def full_description_from(args)
        if superclass_metadata && superclass_metadata[:example_group][:full_description]
          "#{superclass_metadata[:example_group][:full_description]} #{description_from(args)}"
        else
          description_from(args)
        end
      end

      def described_class_from(args)
        if args.first.is_a?(String)
          self.superclass_metadata && self.superclass_metadata[:example_group][:describes]
        else
          args.first
        end
      end

      def file_path_from(metadata, given_file_path=nil)
        given_file_path || file_and_line_number(metadata)[0].strip
      end

      def line_number_from(metadata, given_line_number=nil)
        given_line_number || file_and_line_number(metadata)[1].to_i
      end

      def location_from(metadata)
        "#{metadata[:file_path]}:#{metadata[:line_number]}"
      end

      def file_and_line_number(metadata)
        candidate_entries_from_caller(metadata).first.split(':')
      end

      def candidate_entries_from_caller(metadata)
        metadata[:caller].grep(/\_spec\.rb:/i)
      end

    end
  end
end
