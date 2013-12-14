module RSpec
  module Core
    class ProjectInitializer
      def run
        create_spec_helper_file
        create_dot_rspec_file
      end

      def create_dot_rspec_file
        if File.exist?('.rspec')
          report_exists('.rspec')
        else
          report_creating('.rspec')
          File.open('.rspec','w') do |f|
            f.write File.read(File.expand_path("../project_initializer/dot_rspec", __FILE__))
          end
        end
      end

      def create_spec_helper_file
        if File.exist?('spec/spec_helper.rb')
          report_exists('spec/spec_helper.rb')
        else
          report_creating('spec/spec_helper.rb')
          FileUtils.mkdir_p('spec')
          File.open('spec/spec_helper.rb','w') do |f|
            f.write File.read(File.expand_path("../project_initializer/spec_helper.rb", __FILE__))
          end
        end
      end

      def report_exists(file)
        puts "   exist   #{file}"
      end

      def report_creating(file)
        puts "  create   #{file}"
      end
    end
  end
end
