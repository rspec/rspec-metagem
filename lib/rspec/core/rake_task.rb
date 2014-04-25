require 'rspec/support'
require 'rspec/core/version'
RSpec::Support.require_rspec_support "warnings"

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
      DEFAULT_PATTERN = './spec{,/*/**}/*_spec.rb'

      # Name of task.
      #
      # default:
      #   :spec
      attr_accessor :name

      # Glob pattern to match files.
      #
      # default:
      #   'spec/**/*_spec.rb'
      attr_accessor :pattern

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
        if fail_on_error && !success
          $stderr.puts "#{command} failed"
          exit $?.exitstatus
        end
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

      def files_to_run
        if ENV['SPEC']
          FileList[ ENV['SPEC'] ].sort
        else
          FileList[ pattern ].sort.map(&:shellescape)
        end
      end

      def spec_command
        cmd_parts = []
        cmd_parts << RUBY
        cmd_parts << ruby_opts
        cmd_parts << rspec_load_path
        cmd_parts << "-S" << rspec_path
        cmd_parts << files_to_run
        cmd_parts << rspec_opts
        cmd_parts.flatten.reject(&blank).join(" ")
      end

      def blank
        lambda {|s| s.nil? || s == ""}
      end

      def rspec_load_path
        @rspec_load_path ||= begin
          core_and_support = $LOAD_PATH.grep \
            %r{#{File::SEPARATOR}rspec-(core|support)[^#{File::SEPARATOR}]*#{File::SEPARATOR}lib}

          "-I#{core_and_support.map(&:shellescape).join(File::PATH_SEPARATOR)}"
        end
      end
    end
  end
end
