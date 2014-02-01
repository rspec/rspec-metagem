require 'rspec/support/warnings'
require 'rake'
require 'rake/tasklib'
require 'shellwords'

module RSpec
  module Core
    class RakeTask < ::Rake::TaskLib
      include ::Rake::DSL if defined?(::Rake::DSL)

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
        setup_ivars(args)

        desc "Run RSpec code examples" unless ::Rake.application.last_comment

        task name, *args do |_, task_args|
          RakeFileUtils.__send__(:verbose, verbose) do
            task_block.call(*[self, task_args].slice(0, task_block.arity)) if task_block
            run_task verbose
          end
        end
      end

      def setup_ivars(args)
        @name = args.shift || :spec
        @ruby_opts, @rspec_opts = nil, nil, nil
        @verbose, @fail_on_error = true, true

        @rspec_path = 'rspec'
        @pattern    = './spec{,/*/**}/*_spec.rb'
      end

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
        cmd_parts << "-S" << rspec_path
        cmd_parts << files_to_run
        cmd_parts << rspec_opts
        cmd_parts.flatten.reject(&blank).join(" ")
      end

      def blank
        lambda {|s| s.nil? || s == ""}
      end
    end
  end
end
