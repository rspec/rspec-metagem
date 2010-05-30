require 'optparse'
# http://www.ruby-doc.org/stdlib/libdoc/optparse/rdoc/classes/OptionParser.html

module Rspec
  module Core

    class CommandLineOptions
      DEFAULT_OPTIONS_FILE = 'spec/spec.opts'

      attr_reader :args, :options

      def self.parse(args)
        new(args).parse
      end

      def initialize(args)
        @args = args
        @options = {}
        @drb = false
      end

      def parse
        _parse
        adjust_to_drb
        self
      end

      def _parse
        # TODO when RSpec starts in the Spork process, this incorrectly reads ARGV
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
            # TODO this is in need of some cleanup :)
            class << options[:full_description]; self; end.
              send(:define_method, :pattern_source) do
                o
              end
          end

          opts.on('-o', '--options [PATH]', 'Read configuration options from a file path.  (Defaults to spec/spec.opts)') do |o|
            options[:options_file] = o || DEFAULT_OPTIONS_FILE
          end

          opts.on('-p', '--profile', 'Enable profiling of examples with output of the top 10 slowest examples') do |o|
            options[:profile_examples] = o
          end

          opts.on('-b', '--backtrace', 'Enable full backtrace') do |o|
            options[:full_backtrace] = true
          end

          opts.on('-d', '--debug', 'Enable debugging') do |o|
            options[:debug] = true
          end

          opts.on('-X', '--drb', 'Run examples via DRb') do |o|
            options[:drb] = true
          end

          opts.on('--drb-port [PORT]', 'Port to connect to on the DRb server') do |o|
            options[:drb_port] = o.to_i
          end

          opts.on('-v', '--version', 'Show version') do |o|
            options[:version] = o
          end

          opts.on_tail('-h', '--help', "You're looking at it.") do
            puts opts
            exit
          end
        end.parse!(@args) # TODO check parse! vs parse

        self
      end

      def merge_options_file
        # 1) option file, cli options, rspec core configure
        # TODO: Add options_file to configuration
        # TODO: Store command line options for reference
        options_file = options.delete(:options_file) || DEFAULT_OPTIONS_FILE
        merged_options = parse_spec_file_contents(options_file).merge!(options)
        options.replace merged_options

        adjust_to_drb

        self
      end

      def to_drb_argv
        argv = []
        argv << "--colour" if options[:color_enabled]
        argv << "--formatter" << options[:formatter] if options[:formatter] # TODO preserve string
        argv << "--line_number" << options[:line_number] if options[:line_number]
        argv << "--example" << options[:full_description].pattern_source if options[:full_description]
        # options[:options_file] # TODO check
        argv << "--profile" if options[:profile_examples]
        argv << "--backtrace" if options[:full_backtrace]
        argv << "--version" if options[:version]
        # options[:debug] # TODO check - we're only making to_s for DRb
        # options[:drb] # TODO check - we're only making to_s for DRb
        
        argv + options[:files_or_directories_to_run]
      end

      def drb?
        @drb
      end

      def version?
        !!options[:version] && !drb?
      end

      def drb_port
        options[:drb_port] || 8989
      end

      def apply(config)
        # TODO this is inconsistent - #apply calls this but #parse doesn't (and can't)
        merge_options_file

        options.each do |key, value|
          config.send("#{key}=", value)
        end
      end

      private

      def parse_spec_file_contents(options_file)
        return {} unless File.exist?(options_file)
        spec_file_contents = File.readlines(options_file).map {|l| l.split}.flatten
        self.class.new(spec_file_contents)._parse.options
      end

      def adjust_to_drb
        if @drb || options[:drb]
          options[:debug] = false
          options.delete(:drb)
          @drb = true
        end
      end
    end

  end
end
