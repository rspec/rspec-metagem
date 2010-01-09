module Rspec
  module Core
    class Metadata < Hash
      
      attr_reader :superclass_metadata

      def initialize(superclass_metadata)
        @superclass_metadata = superclass_metadata
        update(@superclass_metadata) if @superclass_metadata
        store(:behaviour, {})
      end

      def behaviour
        self[:behaviour]
      end

      def process(*args)
        extra_metadata = args.last.is_a?(Hash) ? args.pop : {}
        extra_metadata.delete(:behaviour) # Remove it when present to prevent it clobbering the one we setup

        behaviour[:describes] = args.shift unless args.first.is_a?(String)
        behaviour[:describes] ||= self.superclass_metadata && self.superclass_metadata[:behaviour][:describes]
        behaviour[:description] = args.shift || ''

        behaviour[:name] = generate_name
        behaviour[:block] = extra_metadata.delete(:behaviour_block)
        behaviour[:caller] = extra_metadata.delete(:caller)
        behaviour[:file_path] = determine_file_path(extra_metadata.delete(:file_path))
        behaviour[:line_number] = determine_line_number(extra_metadata.delete(:line_number))

        update(extra_metadata)
      end

      def determine_file_path(given_file_path)
        return given_file_path if given_file_path
        possible_files = behaviour[:caller].grep(/\_spec\.rb:/i)
        possible_files.first.split(':').first.strip
      end

      def determine_line_number(given_line_number)
        return given_line_number if given_line_number
        possible_files = behaviour[:caller].grep(/\_spec\.rb:/i)
        possible_files.first.split(':')[1].to_i
      end

      def generate_name
        if superclass_metadata && superclass_metadata.behaviour[:name]
          behaviour[:name] = "#{superclass_metadata.behaviour[:name]} #{behaviour[:description]} "
        else
          behaviour[:name] = "#{behaviour[:describes]} #{behaviour[:description]} "
        end
        behaviour[:name].strip!
      end

    end
  end
end
