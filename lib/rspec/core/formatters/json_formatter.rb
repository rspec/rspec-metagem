require 'rspec/core/formatters/base_formatter'
require 'json'

module RSpec
  module Core
    module Formatters

      class JsonFormatter < BaseFormatter

        attr_reader :output_hash

        def initialize(output)
          super
          @output_hash = {}
        end

        def message(message)
          (@output_hash[:messages] ||= []) << message
        end

        # def example_started(example)
        #   super
        # end
        #
        # def example_passed(example)
        # end
        #
        # def example_pending(example)
        # end
        #
        # def example_failed(example)
        # end


        # def dump_failures
        #   return if failed_examples.empty?
        #   output.puts
        #   output.puts "Failures:"
        #   failed_examples.each_with_index do |example, index|
        #     output.puts
        #     pending_fixed?(example) ? dump_pending_fixed(example, index) : dump_failure(example, index)
        #     dump_backtrace(example)
        #   end
        # end

        def dump_summary(duration, example_count, failure_count, pending_count)
          super(duration, example_count, failure_count, pending_count)
          @output_hash[:summary] = {
            :duration => duration,
            :example_count => example_count,
            :failure_count => failure_count,
            :pending_count => pending_count
          }
          @output_hash[:summary_line] = summary_line(example_count, failure_count, pending_count)

          # Don't print out profiled info if there are failures, it just clutters the output
          dump_profile if profile_examples? && failure_count == 0
        end

        # stolen from BaseTextFormatter
        def summary_line(example_count, failure_count, pending_count)
          summary = pluralize(example_count, "example")
          summary << ", " << pluralize(failure_count, "failure")
          summary << ", #{pending_count} pending" if pending_count > 0
          summary
        end

        # def dump_profile
        #   sorted_examples = examples.sort_by { |example| example.execution_result[:run_time] }.reverse.first(10)
        #   output.puts "\nTop #{sorted_examples.size} slowest examples:\n"
        #   sorted_examples.each do |example|
        #     output.puts "  #{example.full_description}"
        #     output.puts cyan("    #{red(format_seconds(example.execution_result[:run_time]))} #{red("seconds")} #{format_caller(example.location)}")
        #   end
        # end

        # def dump_pending
        #   unless pending_examples.empty?
        #     output.puts
        #     output.puts "Pending:"
        #     pending_examples.each do |pending_example|
        #       output.puts yellow("  #{pending_example.full_description}")
        #       output.puts cyan("    # #{pending_example.execution_result[:pending_message]}")
        #       output.puts cyan("    # #{format_caller(pending_example.location)}")
        #       if pending_example.execution_result[:exception] \
        #         && RSpec.configuration.show_failures_in_pending_blocks?
        #         dump_failure_info(pending_example)
        #         dump_backtrace(pending_example)
        #       end
        #     end
        #   end
        # end

        # def seed(number)
        #   output.puts
        #   output.puts "Randomized with seed #{number}"
        #   output.puts
        # end

        def stop
          super
          @output_hash[:examples] = examples.map do |example|
            {
              :description => example.description,
              :full_description => example.full_description,
              :status => example.execution_result[:status],
              # :example_group,
              # :execution_result,
              :file_path => example.metadata[:file_path],
              :line_number  => example.metadata[:line_number],
            }.tap do |hash|
              if e=example.exception
                hash[:exception] =  {
                  :class => e.class.name,
                  :message => e.message,
                  :backtrace => e.backtrace,
                }
              end
            end
          end
        end

        def close
          output.write @output_hash.to_json
          output.close if IO === output && output != $stdout
        end

      protected


      private

        # def format_caller(caller_info)
        #   backtrace_line(caller_info.to_s.split(':in `block').first)
        # end
        #
        # def dump_backtrace(example)
        #   format_backtrace(example.execution_result[:exception].backtrace, example).each do |backtrace_info|
        #     output.puts cyan("#{long_padding}# #{backtrace_info}")
        #   end
        # end
        #
        # def dump_pending_fixed(example, index)
        #   output.puts "#{short_padding}#{index.next}) #{example.full_description} FIXED"
        #   output.puts blue("#{long_padding}Expected pending '#{example.metadata[:execution_result][:pending_message]}' to fail. No Error was raised.")
        # end
        #
        # def pending_fixed?(example)
        #   example.execution_result[:exception].pending_fixed?
        # end
        #
        # def dump_failure(example, index)
        #   output.puts "#{short_padding}#{index.next}) #{example.full_description}"
        #   dump_failure_info(example)
        # end
        #
        # def dump_failure_info(example)
        #   exception = example.execution_result[:exception]
        #   output.puts "#{long_padding}#{red("Failure/Error:")} #{red(read_failed_line(exception, example).strip)}"
        #   output.puts "#{long_padding}#{red(exception.class.name << ":")}" unless exception.class.name =~ /RSpec/
        #   exception.message.split("\n").each { |line| output.puts "#{long_padding}  #{red(line)}" } if exception.message
        #   if shared_group = find_shared_group(example)
        #     dump_shared_failure_info(shared_group)
        #   end
        # end
        #
        # def dump_shared_failure_info(group)
        #   output.puts "#{long_padding}Shared Example Group: \"#{group.metadata[:shared_group_name]}\" called from " +
        #     "#{backtrace_line(group.metadata[:example_group][:location])}"
        # end
        #
        # def find_shared_group(example)
        #   group_and_ancestors(example).find {|group| group.metadata[:shared_group_name]}
        # end
        #
        # def group_and_ancestors(example)
        #   example.example_group.ancestors + [example.example_group]
        # end
      end
    end
  end
end
