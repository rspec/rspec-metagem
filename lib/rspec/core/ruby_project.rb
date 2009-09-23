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
        # This is borrowed (slightly modified) from Scott Taylor's
        # project_path project:
        #   http://github.com/smtlaissezfaire/project_path
        Pathname(File.expand_path('.')).ascend do |path|
          if File.exists?(File.join(path, "spec"))
            return path
          end
        end
      end
      
      module_function :add_to_load_path
      module_function :root
      module_function :determine_root
    end
  end
end