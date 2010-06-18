#!/usr/bin/env ruby

require 'rake'
require 'rake/tasklib'

module RSpec
  module Core

    class RakeTask < ::Rake::TaskLib

      # Name of task. (default is :spec)
      attr_accessor :name

      # If true, requests that the specs be run with the warning flag set.
      # E.g. warning=true implies "ruby -w" used to run the specs. Defaults to false.
      attr_accessor :warning

      # Glob pattern to match files. (default is 'spec/**/*_spec.rb')
      attr_accessor :pattern

      # The options to pass to ruby.  Defaults to blank
      attr_accessor :ruby_opts

      # Whether or not to fail Rake when an error occurs (typically when examples fail).
      # Defaults to true.
      attr_accessor :fail_on_error

      # A message to print to stderr when there are failures.
      attr_accessor :failure_message

      # Use verbose output. If this is set to true, the task will print
      # the executed spec command to stdout. Defaults to false.
      attr_accessor :verbose

      # Use rcov for code coverage? defaults to false
      attr_accessor :rcov

      # Path to rcov.  You can set this to 'bundle exec rcov' if you bundle rcov.
      attr_accessor :rcov_path

      # The options to pass to rcov.  Defaults to blank
      attr_accessor :rcov_opts

      def initialize(*args)
        @name = args.shift || :spec
        @pattern, @rcov_path, @rcov_opts, @ruby_opts = nil, nil, nil, nil
        @warning, @rcov = false, false
        @fail_on_error = true

        yield self if block_given?
        @rcov_path ||= 'rcov'
        @pattern ||= './spec/**/*_spec.rb'
        define
      end

      def define # :nodoc:
        actual_name = Hash === name ? name.keys.first : name
        desc("Run RSpec code examples") unless ::Rake.application.last_comment

        task name do
          RakeFileUtils.send(:verbose, verbose) do
            if files_to_run.empty?
              puts "No examples matching #{pattern} could be found"
            else
              cmd_parts = [ '-Ilib', '-Ispec' ]
              cmd_parts << "-w" if warning

              if rcov
                command_to_run = rcov_command(cmd_parts)
                command_to_run.inspect if verbose

                unless system(command_to_run)
                  STDERR.puts failure_message if failure_message
                  raise("#{command_to_run} failed") if fail_on_error
                end
              else
                cmd_parts.concat(files_to_run)
                puts cmd.inspect if verbose

                require 'rspec/core'
                RSpec::Core::Runner.disable_at_exit_hook!

                unless RSpec::Core::Runner.run(cmd_parts, $stderr, $stdout)
                  STDERR.puts failure_message if failure_message
                  raise("RSpec::Core::Runner.run with args #{cmd_parts.inspect} failed") if fail_on_error
                end
              end

            end
          end
        end

        self
      end

      def files_to_run # :nodoc:
        FileList[ pattern ].to_a
      end

      private

      def rcov_command(cmd_parts)
        cmd_parts.unshift runner_options
        cmd_parts.unshift runner
        cmd_parts += files_to_run.map { |fn| %["#{fn}"] }
        cmd_parts.join(" ")
      end

      def runner
        rcov ? rcov_path : RUBY
      end

      def runner_options
        rcov ? [rcov_opts] : [ruby_opts]
      end

    end

  end
end
