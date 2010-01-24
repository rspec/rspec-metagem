require 'optparse'
# http://www.ruby-doc.org/stdlib/libdoc/optparse/rdoc/classes/OptionParser.html

module Rspec
  module Core

    class CommandLineOptions
      
      attr_reader :args, :options
      
      def self.parse(args)
        new(args).parse
      end

      def initialize(args)
        @args = args
        @options = {}
      end
      
      def files_to_run
        options[:files_to_run]
      end

      def parse
        possible_files = OptionParser.new do |opts|
          opts.banner = "Usage: rspec [options] [files or directories]"

          opts.on('-c', '--[no-]color', '--[no-]colour', 'Enable color in the output') do |o|
            options[:color_enabled] = o
          end
          
          opts.on('-f', '--formatter [FORMATTER]', 'Choose an optional formatter') do |o|
            options[:formatter] = o
          end

          opts.on('-p', '--profile', 'Enable profiling of examples with output of the top 10 slowest examples') do |o|
            options[:profile_examples] = o
          end

          opts.on_tail('-h', '--help', "You're looking at it.") do 
            puts opts
          end
        end.parse!(@args)

        options[:files_to_run] = expand_files_from(possible_files)
        self 
      end

      def expand_files_from(fileset)
        fileset.inject([]) do |files, file|
          if File.directory?(file)
            files += Dir["#{file}/**/*_spec.rb"]
          else
            files << file
          end
        end
      end
      
      def apply(config)
        options.each do |key, value|
          config.send("#{key}=", value)
        end
      end

    end

  end
end
