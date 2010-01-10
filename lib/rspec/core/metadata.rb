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
        store(:behaviour, {})
        yield self if block_given?
      end

      def process(*args)
        extra_metadata = args.last.is_a?(Hash) ? args.pop : {}
        extra_metadata.delete(:behaviour) # Remove it when present to prevent it clobbering the one we setup

        self[:behaviour][:describes] = args.shift unless args.first.is_a?(String)
        self[:behaviour][:describes] ||= self.superclass_metadata && self.superclass_metadata[:behaviour][:describes]
        self[:behaviour][:description] = args.shift || ''

        self[:behaviour][:name] = determine_name
        self[:behaviour][:block] = extra_metadata.delete(:behaviour_block)
        self[:behaviour][:caller] = extra_metadata.delete(:caller)
        self[:behaviour][:file_path] = determine_file_path(extra_metadata.delete(:file_path))
        self[:behaviour][:line_number] = determine_line_number(extra_metadata.delete(:line_number))

        update(extra_metadata)
      end

    private

      def possible_files
        self[:behaviour][:caller].grep(/\_spec\.rb:/i)
      end

      def determine_file_path(given_file_path=nil)
        return given_file_path if given_file_path
        possible_files.first.split(':').first.strip
      end

      def determine_line_number(given_line_number=nil)
        return given_line_number if given_line_number
        possible_files.first.split(':')[1].to_i
      end

      def determine_name
        if superclass_metadata && superclass_metadata[:behaviour][:name]
          self[:behaviour][:name] = "#{superclass_metadata[:behaviour][:name]} #{self[:behaviour][:description]}".strip 
        else
          self[:behaviour][:name] = "#{self[:behaviour][:describes]} #{self[:behaviour][:description]}".strip
        end
      end

    end
  end
end
