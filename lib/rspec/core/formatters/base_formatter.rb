module Rspec

  module Core

    module Formatters

      class BaseFormatter
        attr_accessor :behaviour
        attr_reader :example_count, :duration, :examples

        def initialize
          @example_count = 0
          @examples = []
          @behaviour = nil
        end

        def configuration
          Rspec::Core.configuration
        end

        def output
          Rspec::Core.configuration.output
        end

        def trace(&blk)
          Rspec::Core.configuration.trace(trace_override_flag, &blk)
        end

        # Allow setting trace at the behaviour level as well globally
        def trace_override_flag
          behaviour && behaviour.metadata[:trace]
        end

        def profile_examples?
          Rspec::Core.configuration.profile_examples
        end

        def color_enabled?
          configuration.color_enabled?
        end

        def pending_examples
          @pending_examples ||= ::Rspec::Core.world.find(examples, :positive, :execution_result => { :status => 'pending' })
        end

        def failed_examples
          @failed_examples ||= ::Rspec::Core.world.find(examples, :positive, :execution_result => { :status => 'failed' })
        end

        # This method is invoked before any examples are run, right after
        # they have all been collected. This can be useful for special
        # formatters that need to provide progress on feedback (graphical ones)
        #
        # This method will only be invoked once, and the next one to be invoked
        # is #add_behaviour
        def start(example_count)
          @example_count = example_count
        end

        def example_finished(example)
          examples << example
        end

        # This method is invoked at the beginning of the execution of each behaviour.
        # +behaviour+ is the behaviour.
        #
        # The next method to be invoked after this is #example_failed or #example_finished
        def add_behaviour(behaviour)
          @behaviour = behaviour
        end

        # This method is invoked after all of the examples have executed. The next method
        # to be invoked after this one is #dump_failure (once for each failed example),
        def start_dump(duration)
          @duration = duration
        end

        # Dumps detailed information about each example failure.
        def dump_failures
        end

        # This method is invoked after the dumping of examples and failures.
        def dump_summary
        end

        # This gets invoked after the summary if option is set to do so.
        def dump_pending
        end

        # This method is invoked at the very end. Allows the formatter to clean up, like closing open streams.
        def close
        end

        def format_backtrace(backtrace, example)
          return "" unless backtrace
          return backtrace if example.metadata[:full_backtrace] == true

          cleansed = backtrace.select { |line| backtrace_line(line) }
          # Kick the describe stack info off the list, just keep the line the problem happened on from that file
          # cleansed = [cleansed.detect { |line| line.split(':').first == example.metadata[:caller].split(':').first }] if cleansed.size > 1 
          cleansed.empty? ? backtrace : cleansed
        end

        protected

        def backtrace_line(line)
          return nil if configuration.cleaned_from_backtrace?(line)
          line.sub!(/\A([^:]+:\d+)$/, '\\1')
          return nil if line == '-e:1'
          line
        end

        def read_failed_line(exception, example)
          original_file = example.file_path.to_s.downcase
          matching_line = exception.backtrace.detect { |line| line.split(':').first.downcase == original_file.downcase }

          return "Unable to find matching line from backtrace" if matching_line.nil?

          file_path, line_number = matching_line.split(':')
          if File.exist?(file_path)
            open(file_path, 'r') { |f| f.readlines[line_number.to_i - 1] }
          else
            "Unable to find #{file_path} to read failed line"
          end
        end

      end

    end
  end

end