require 'optparse'
# http://www.ruby-doc.org/stdlib/libdoc/optparse/rdoc/classes/OptionParser.html

module Rspec
  module Core

    class CommandLineOptions
      LOCAL_OPTIONS_FILE  = ".rspecrc"
      GLOBAL_OPTIONS_FILE = File.join(File.expand_path("~"), ".rspecrc")
      
      attr_reader :args, :options
      
      def self.parse(args)
        new(args).parse
      end

      def initialize(args)
        @args = args
        @options = {}
      end
      
      def parse
        @options[:files_or_directories_to_run] = parser.parse(@args)
        self 
      end

      def apply(config)
        global_options.merge(local_options).merge(@options).each do |key, value|
          config.send("#{key}=", value)
        end
      end

    private

      def parser
        @parser ||= OptionParser.new do |parser|
          parser.banner = "Usage: rspec [options] [files or directories]"

          parser.on('-c', '--[no-]color', '--[no-]colour', 'Enable color in the output') do |o|
            @options[:color_enabled] = o
          end
          
          parser.on('-f', '--formatter FORMATTER', 'Choose a formatter',
                  '  [p]rogress (default - dots)',
                  '  [d]ocumentation (group and example names)') do |o|
            @options[:formatter] = o
          end

          parser.on('-l', '--line_number LINE', 'Specify the line number of a single example to run') do |o|
            @options[:line_number] = o
          end

          parser.on('-e', '--example PATTERN', "Run examples whose full descriptions match this pattern",
                  "(PATTERN is compiled into a Ruby regular expression)") do |o|
            @options[:full_description] = /#{o}/
          end

          parser.on('-o', '--options PATH', 'Read configuration options from a file path.  (Defaults to spec/spec.parser)') do |o|
            @options[:options_file] = o || local_options_file
          end
          
          parser.on('-p', '--profile', 'Enable profiling of examples with output of the top 10 slowest examples') do |o|
            @options[:profile_examples] = o
          end

          parser.on('-b', '--backtrace', 'Enable full backtrace') do |o|
            @options[:full_backtrace] = true
          end

          parser.on('-d', '--debug', 'Enable debugging') do |o|
            @options[:debug] = true
          end

          parser.on_tail('-h', '--help', "You're looking at it.") do 
            puts parser
            exit
          end
        end
      end

      def global_options
        parse_options_file(GLOBAL_OPTIONS_FILE)
      end

      def local_options
        parse_options_file(local_options_file)
      end

      def local_options_file
        return @options.delete(:options_file) if @options[:options_file]
        return LOCAL_OPTIONS_FILE if File.exist?(LOCAL_OPTIONS_FILE)
        Rspec.deprecate("spec/spec.opts", ".rspecrc or ~/.rspecrc", "2.0.0") if File.exist?("spec/spec.opts")
        "spec/spec.opts"
      end
      
      def parse_options_file(options_file)
        return {} unless File.exist?(options_file)
        options_file_contents = File.readlines(options_file).map {|l| l.split}.flatten
        self.class.new(options_file_contents).parse.options
      end

    end

  end
end
