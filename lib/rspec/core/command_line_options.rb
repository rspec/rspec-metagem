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
      
      def parse
        options[:files_or_directories_to_run] = OptionParser.new do |opts|
          opts.banner = "Usage: rspec [options] [files or directories]"

          opts.on('-c', '--[no-]color', '--[no-]colour', 'Enable color in the output') do |o|
            options[:color_enabled] = o
          end
          
          opts.on('-f', '--formatter [FORMATTER]', 'Choose an optional formatter') do |o|
            options[:formatter] = o
          end

          opts.on('-l', '--line_number [LINE]', 'Specify the line number of a single example to run') do |o|
            options[:line_number] = o
          end

          opts.on('-e', '--example [PATTERN]', "Run examples whose full descriptions match this pattern",
                  "(PATTERN is compiled into a Ruby regular expression)") do |o|
            options[:full_description] = /#{o}/
          end

          opts.on('-p', '--profile', 'Enable profiling of examples with output of the top 10 slowest examples') do |o|
            options[:profile_examples] = o
          end

          opts.on('-b', '--backtrace', 'Enable full backtrace') do |o|
            options[:full_backtrace] = true
          end

          opts.on_tail('-h', '--help', "You're looking at it.") do 
            puts opts
            exit
          end
        end.parse!(@args)

        self 
      end

      def apply(config)
        options.each do |key, value|
          config.send("#{key}=", value)
        end
      end

    end

  end
end
