module Rspec
  module Core
    module RubyProject
      def add_to_load_path(dir)
        dir = File.join(root, dir)
        $LOAD_PATH.unshift(dir) unless $LOAD_PATH.include?(dir)
      end

      def root # :nodoc:
        require 'pathname'
        @project_root ||= determine_root
      end

      def determine_root # :nodoc:
        find_first_parent_containing('spec') || '.'
      end

      def find_first_parent_containing(dir)
        # This is borrowed (slightly modified) from Scott Taylor's
        # project_path project:
        #   http://github.com/smtlaissezfaire/project_path
        find_directory_parent('.') do |path|
          File.exists?(File.join(path, dir))
        end
      end

      def find_directory_parent(path_start, &block)
        Pathname(File.expand_path(path_start)).ascend do |path|
          return path if block.call(path)
        end
      end
      
      module_function :add_to_load_path
      module_function :root
      module_function :determine_root
      module_function :find_first_parent_containing
      module_function :find_directory_parent
    end
  end
end
