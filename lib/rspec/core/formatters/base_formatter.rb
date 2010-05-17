module RSpec
  module Core
    module Formatters

      class BaseFormatter
        include Helpers
        attr_accessor :example_group
        attr_reader :example_count, :duration, :examples

        def initialize
          @example_count = 0
          @examples = []
          @example_group = nil
        end

        def output
          configuration.output
        end

        def pending_examples
          @pending_examples ||= ::RSpec.world.find(examples, :execution_result => { :status => 'pending' })
        end

        def failed_examples
          @failed_examples ||= ::RSpec.world.find(examples, :execution_result => { :status => 'failed' })
        end

        def report(count)
          sync_output do
            start(count)
            # TODO - spec that we still dump even when there's
            # an exception
            begin
              yield self
            ensure
              stop
              dump(@duration)
              close
            end
          end
        end

        # This method is invoked before any examples are run, right after
        # they have all been collected. This can be useful for special
        # formatters that need to provide progress on feedback (graphical ones)
        #
        # This method will only be invoked once, and the next one to be invoked
        # is #add_example_group
        def start(example_count)
          @start = Time.now
          @example_count = example_count
        end

        def stop
          @duration = Time.now - @start
        end

        def example_finished(example)
          examples << example
        end

        # This method is invoked at the beginning of the execution of each example group.
        # +example_group+ is the example_group.
        #
        # The next method to be invoked after this is #example_failed or #example_finished
        def add_example_group(example_group)
          @example_group = example_group
        end

        def dump(duration)
          start_dump(duration)
          dump_failures
          dump_summary
          dump_pending
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

        def configuration
          RSpec.configuration
        end

        def backtrace_line(line)
          return nil if configuration.cleaned_from_backtrace?(line)
          line.sub!(File.expand_path("."), ".")
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

        def sync_output
          begin
            old_sync, output.sync = output.sync, true if output_supports_sync
            yield
          ensure
            output.sync = old_sync if output_supports_sync
          end
        end

        def output_supports_sync
          output.respond_to?(:sync=)
        end

        def profile_examples?
          configuration.profile_examples
        end

        def color_enabled?
          configuration.color_enabled?
        end

      end

    end
  end
end
