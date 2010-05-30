require 'optparse'
# http://www.ruby-doc.org/stdlib/libdoc/optparse/rdoc/classes/OptionParser.html

module RSpec
  module Core

    class ConfigurationOptions
      LOCAL_OPTIONS_FILE  = ".rspec"
      GLOBAL_OPTIONS_FILE = File.join(File.expand_path("~"), ".rspec")
      
      attr_reader :args, :options
      
      def initialize(args)
        @args = args
        @options = {}
        @drb = false
        parse_command_line_options
      end
      
      def apply_to(config)
        merged_options.each do |key, value|
          config.send("#{key}=", value) rescue nil
        end
      end

      def parse_command_line_options
        @parsed_options ||= begin
        cloptions = Parser.parse!(@args)
        cloptions[:files_or_directories_to_run] = @args
        @options = [global_options, local_options, cloptions].inject do |merged, options|
          merged.merge(options)
        end

        adjust_to_drb

        @merged_options = @options
        @options
                            end
      end

      def version?
        !!options[:version] && !drb?
      end

      def drb?
        @drb
      end

      def drb_port
        options[:drb_port] || 8989
      end

      def to_drb_argv
        argv = []
        argv << "--colour" if merged_options[:color_enabled]
        argv << "--formatter" << merged_options[:formatter] if merged_options[:formatter] # TODO preserve string
        argv << "--line_number" << merged_options[:line_number] if merged_options[:line_number]
        argv << "--example" << merged_options[:full_description].source if merged_options[:full_description]
        # merged_options[:options_file] # TODO check
        argv << "--profile" if merged_options[:profile_examples]
        argv << "--backtrace" if merged_options[:full_backtrace]
        argv << "--version" if merged_options[:version]
        # merged_options[:debug] # TODO check - we're only making to_s for DRb
        # merged_options[:drb] # TODO check - we're only making to_s for DRb
        
        argv + merged_options[:files_or_directories_to_run]
      end

      def merged_options
        @merged_options
      end

    private

      def command_line_options
        parse_command_line_options
      end

      class Parser
        def self.parse!(args)
          new.parse!(args)
        end

        class << self
          alias_method :parse, :parse!
        end

        def parse!(args)
          options = {}
          parser(options).parse!(args)
          options
        end

        alias_method :parse, :parse!

        def parser(options)
          OptionParser.new do |parser|
            parser.banner = "Usage: rspec [options] [files or directories]"

            parser.on('-b', '--backtrace', 'Enable full backtrace') do |o|
              options[:full_backtrace] = true
            end

            parser.on('-c', '--[no-]color', '--[no-]colour', 'Enable color in the output') do |o|
              options[:color_enabled] = o
            end
            
            parser.on('-d', '--debug', 'Enable debugging') do |o|
              options[:debug] = true
            end

            parser.on('-e', '--example PATTERN', "Run examples whose full descriptions match this pattern",
                    "(PATTERN is compiled into a Ruby regular expression)") do |o|
              options[:full_description] = /#{o}/
            end

            parser.on('-f', '--formatter FORMATTER', 'Choose a formatter',
                    '  [p]rogress (default - dots)',
                    '  [d]ocumentation (group and example names)') do |o|
              options[:formatter] = o
            end

            parser.on_tail('-h', '--help', "You're looking at it.") do 
              puts parser
              exit
            end

            parser.on('-I DIRECTORY', 'specify $LOAD_PATH directory (may be used more than once)') do |dir|
              options[:libs] ||= []
              options[:libs] << dir
            end

            parser.on('-l', '--line_number LINE', 'Specify the line number of a single example to run') do |o|
              options[:line_number] = o
            end

            parser.on('-o', '--options PATH', 'Read configuration options from a file path.  (Defaults to spec/spec.parser)') do |o|
              options[:options_file] = o || local_options_file
            end
            
            parser.on('-p', '--profile', 'Enable profiling of examples with output of the top 10 slowest examples') do |o|
              options[:profile_examples] = o
            end

            parser.on('-v', '--version', 'Show version') do |o|
              options[:version] = o
            end

            parser.on('-X', '--drb', 'Run examples via DRb') do |o|
              options[:drb] = true
            end

            parser.on('--drb-port [PORT]', 'Port to connect to on the DRb server') do |o|
              options[:drb_port] = o.to_i
            end

          end
        end
      end

      def global_options
        parse_options_file(GLOBAL_OPTIONS_FILE)
      end

      def local_options
        parse_options_file(local_options_file)
      end
      
      def parse_options_file(path)
        Parser.parse(args_from_options_file(path))
      end

      def args_from_options_file(path)
        return [] unless File.exist?(path)
        File.readlines(path).map {|l| l.split}.flatten
      end

      def local_options_file
        return @options.delete(:options_file) if @options[:options_file]
        return LOCAL_OPTIONS_FILE if File.exist?(LOCAL_OPTIONS_FILE)
        RSpec.deprecate("spec/spec.opts", ".rspec or ~/.rspec", "2.0.0") if File.exist?("spec/spec.opts")
        "spec/spec.opts"
      end

      def adjust_to_drb
        if @drb || options[:drb]
          options[:debug] = false
          @drb = options.delete(:drb)
        end
      end
    end
  end
end
