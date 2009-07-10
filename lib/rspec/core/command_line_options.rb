require 'optparse'
# http://www.ruby-doc.org/stdlib/libdoc/optparse/rdoc/classes/OptionParser.html

module Rspec
  module Core

    class CommandLineOptions
      
      attr_reader :args, :config
      
      def self.parse(args, config)
        cli_options = new(args, config)
        cli_options.parse
      end

      def initialize(args, config)
        @args, @config = args, config
      end

      def parse
        possible_files = OptionParser.new do |opts|
          opts.banner = "Usage: rspec [options] [files or directories]"

          opts.on('-c', '--[no-]color', 'Enable color in the output') do |c|
            @config.color_enabled = c
          end
          
          opts.on('-f', '--formatter [FORMATTER]', 'Choose an optional formatter') do |f|
            @config.formatter = f
          end

          opts.on('-p', '--profile', 'Enable profiling of examples with output of the top 10 slowest examples') do |p|
            @config.profile_examples = p
          end

        end.parse!(@args)

        config.files_to_run = possible_files
      end

    end

  end
end
