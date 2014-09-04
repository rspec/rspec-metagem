require 'rake'
require 'rake/tasklib'
require 'shellwords'

module RSpec
  module Core
    # Rspec rake task
    #
    # @see Rakefile
    class RakeTask < ::Rake::TaskLib
      include ::Rake::DSL if defined?(::Rake::DSL)

      # Default path to the rspec executable
      DEFAULT_RSPEC_PATH = File.expand_path('../../../../exe/rspec', __FILE__)

      # Default pattern for spec files.
      DEFAULT_PATTERN = 'spec/**{,/*/**}/*_spec.rb'

      # Name of task.
      #
      # default:
      #   :spec
      attr_accessor :name

      # Files matching this pattern will be loaded.
      #
      # default:
      #   'spec/**{,/*/**}/*_spec.rb'
      attr_accessor :pattern

      # Files matching this pattern will be excluded.
      #
      # default:
      #   'spec/**/*_spec.rb'
      attr_accessor :exclude_pattern

      # Whether or not to fail Rake when an error occurs (typically when examples fail).
      #
      # default:
      #   true
      attr_accessor :fail_on_error

      # A message to print to stderr when there are failures.
      attr_accessor :failure_message

      # Use verbose output. If this is set to true, the task will print the
      # executed spec command to stdout.
      #
      # default:
      #   true
      attr_accessor :verbose

      # Command line options to pass to ruby.
      #
      # default:
      #   nil
      attr_accessor :ruby_opts

      # Path to rspec
      #
      # default:
      #   'rspec'
      attr_accessor :rspec_path

      # Command line options to pass to rspec.
      #
      # default:
      #   nil
      attr_accessor :rspec_opts

      def initialize(*args, &task_block)
        @name          = args.shift || :spec
        @ruby_opts     = nil
        @rspec_opts    = nil
        @verbose       = true
        @fail_on_error = true
        @rspec_path    = DEFAULT_RSPEC_PATH
        @pattern       = DEFAULT_PATTERN

        define(args, &task_block)
      end

      # @private
      def run_task(verbose)
        command = spec_command

        begin
          puts command if verbose
          success = system(command)
        rescue
          puts failure_message if failure_message
        end

        return unless fail_on_error && !success

        $stderr.puts "#{command} failed"
        exit $?.exitstatus
      end

    private

      # @private
      def define(args, &task_block)
        desc "Run RSpec code examples" unless ::Rake.application.last_comment

        task name, *args do |_, task_args|
          RakeFileUtils.__send__(:verbose, verbose) do
            task_block.call(*[self, task_args].slice(0, task_block.arity)) if task_block
            run_task verbose
          end
        end
      end

      def file_inclusion_specification
        if ENV['SPEC']
          FileList[ ENV['SPEC']].sort
        elsif File.exist?(pattern)
          # The provided pattern is a directory or a file, not a file glob. Historically, this
          # worked because `FileList[some_dir]` would return `[some_dir]` which would
          # get passed to `rspec` and cause it to load files under that dir that match
          # the default pattern. To continue working, we need to pass it on to `rspec`
          # directly rather than treating it as a `--pattern` option.
          #
          # TODO: consider deprecating support for this and removing it in RSpec 4.
          pattern.shellescape
        else
          "--pattern #{pattern.shellescape}"
        end
      end

      def file_exclusion_specification
        " --exclude-pattern #{exclude_pattern.shellescape}" if exclude_pattern
      end

      def spec_command
        cmd_parts = []
        cmd_parts << RUBY
        cmd_parts << ruby_opts
        cmd_parts << rspec_load_path
        cmd_parts << rspec_path
        cmd_parts << file_inclusion_specification
        cmd_parts << file_exclusion_specification
        cmd_parts << rspec_opts
        cmd_parts.flatten.reject(&blank).join(" ")
      end

      def blank
        lambda { |s| s.nil? || s == "" }
      end

      def rspec_load_path
        @rspec_load_path ||= begin
          core_and_support = $LOAD_PATH.grep(
            /#{File::SEPARATOR}rspec-(core|support)[^#{File::SEPARATOR}]*#{File::SEPARATOR}lib/
          )

          "-I#{core_and_support.map(&:shellescape).join(File::PATH_SEPARATOR)}"
        end
      end
    end
  end
end
