require 'rspec/core/formatters/base_formatter'
require 'set'

module RSpec
  module Core
    module Formatters

      # Base for all of RSpec's built-in formatters. See RSpec::Core::Formatters::BaseFormatter
      # to learn more about all of the methods called by the reporter.
      #
      # @see RSpec::Core::Formatters::BaseFormatter
      # @see RSpec::Core::Reporter
      class BaseTextFormatter < BaseFormatter
        def message(message)
          output.puts message
        end

        def dump_failures
          return if failed_examples.empty?
          output.puts
          output.puts "Failures:"
          failed_examples.each_with_index do |example, index|
            output.puts
            pending_fixed?(example) ? dump_pending_fixed(example, index) : dump_failure(example, index)
            dump_backtrace(example)
          end
        end

        # @api public
        #
        # Colorizes the output red for failure, yellow for
        # pending, and green otherwise.
        #
        # @param [String] string
        def colorise_summary(summary)
          if failure_count > 0
            color(summary, RSpec.configuration.failure_color)
          elsif pending_count > 0
            color(summary, RSpec.configuration.pending_color)
          else
            color(summary, RSpec.configuration.success_color)
          end
        end

        def dump_summary(duration, example_count, failure_count, pending_count)
          super(duration, example_count, failure_count, pending_count)
          dump_profile if profile_examples?
          output.puts "\nFinished in #{format_duration(duration)}\n"
          output.puts colorise_summary(summary_line(example_count, failure_count, pending_count))
          dump_commands_to_rerun_failed_examples
        end

        # @api public
        #
        # Outputs commands which can be used to re-run failed examples.
        #
        def dump_commands_to_rerun_failed_examples
          return if failed_examples.empty?
          output.puts
          output.puts("Failed examples:")
          output.puts

          failed_examples.each do |example|
            output.puts(failure_color("rspec #{RSpec::Core::Metadata::relative_path(example.location)}") + " " + detail_color("# #{example.full_description}"))
          end
        end

        # @api public
        #
        # Outputs the slowest examples in a report when using `--profile COUNT` (default 10).
        #
        def dump_profile
          number_of_examples = RSpec.configuration.profile_examples
          sorted_examples = examples.sort_by {|example|
            example.execution_result[:run_time] }.reverse.first(number_of_examples)

          total, slows = [examples, sorted_examples].map {|exs|
            exs.inject(0.0) {|i, e| i + e.execution_result[:run_time] }}

          time_taken = slows / total
          percentage = '%.1f' % ((time_taken.nan? ? 0.0 : time_taken) * 100)

          output.puts "\nTop #{sorted_examples.size} slowest examples (#{format_seconds(slows)} seconds, #{percentage}% of total time):\n"

          sorted_examples.each do |example|
            output.puts "  #{example.full_description}"
            output.puts detail_color("    #{failure_color(format_seconds(example.execution_result[:run_time]))} #{failure_color("seconds")} #{format_caller(example.location)}")
          end
        end

        # @api public
        #
        # Outputs summary with number of examples, failures and pending.
        #
        def summary_line(example_count, failure_count, pending_count)
          summary = pluralize(example_count, "example")
          summary << ", " << pluralize(failure_count, "failure")
          summary << ", #{pending_count} pending" if pending_count > 0
          summary
        end

        def dump_pending
          unless pending_examples.empty?
            output.puts
            output.puts "Pending:"
            pending_examples.each do |pending_example|
              output.puts pending_color("  #{pending_example.full_description}")
              output.puts detail_color("    # #{pending_example.execution_result[:pending_message]}")
              output.puts detail_color("    # #{format_caller(pending_example.location)}")
              if pending_example.execution_result[:exception] \
                && RSpec.configuration.show_failures_in_pending_blocks?
                dump_failure_info(pending_example)
                dump_backtrace(pending_example)
              end
            end
          end
        end

        def seed(number)
          output.puts
          output.puts "Randomized with seed #{number}"
          output.puts
        end

        def close
          output.close if IO === output && output != $stdout
        end

        VT100_COLORS = {
          :black => 30,
          :red => 31,
          :green => 32,
          :yellow => 33,
          :blue => 34,
          :magenta => 35,
          :cyan => 36,
          :white => 37
        }

        VT100_COLOR_CODES = VT100_COLORS.values.to_set

        def color_code_for(code_or_symbol)
          if VT100_COLOR_CODES.include?(code_or_symbol)
            code_or_symbol
          else
            VT100_COLORS.fetch(code_or_symbol) do
              color_code_for(:white)
            end
          end
        end

        def colorize(text, code_or_symbol)
          "\e[#{color_code_for(code_or_symbol)}m#{text}\e[0m"
        end

      protected

        def bold(text)
          color_enabled? ? "\e[1m#{text}\e[0m" : text
        end

        def color(text, color_code)
          color_enabled? ? colorize(text, color_code) : text
        end

        def failure_color(text)
          color(text, RSpec.configuration.failure_color)
        end

        def success_color(text)
          color(text, RSpec.configuration.success_color)
        end

        def pending_color(text)
          color(text, RSpec.configuration.pending_color)
        end

        def fixed_color(text)
          color(text, RSpec.configuration.fixed_color)
        end

        def detail_color(text)
          color(text, RSpec.configuration.detail_color)
        end

        def default_color(text)
          color(text, RSpec.configuration.default_color)
        end

        def red(text)
          RSpec.deprecate("RSpec::Core::Formatters::BaseTextFormatter#red", "#failure_color", "3.0")
          color(text, :red)
        end

        def green(text)
          RSpec.deprecate("RSpec::Core::Formatters::BaseTextFormatter#green", "#success_color", "3.0")
          color(text, :green)
        end

        def yellow(text)
          RSpec.deprecate("RSpec::Core::Formatters::BaseTextFormatter#yellow", "#pending_color", "3.0")
          color(text, :yellow)
        end

        def blue(text)
          RSpec.deprecate("RSpec::Core::Formatters::BaseTextFormatter#blue", "#fixed_color", "3.0")
          color(text, :blue)
        end

        def magenta(text)
          RSpec.deprecate("RSpec::Core::Formatters::BaseTextFormatter#magenta", nil, "3.0")
          color(text, :magenta)
        end

        def cyan(text)
          RSpec.deprecate("RSpec::Core::Formatters::BaseTextFormatter#cyan", "#detail_color", "3.0")
          color(text, :cyan)
        end

        def white(text)
          RSpec.deprecate("RSpec::Core::Formatters::BaseTextFormatter#white", "#default_color", "3.0")
          color(text, :white)
        end

        def short_padding
          '  '
        end

        def long_padding
          '     '
        end

      private

        def format_caller(caller_info)
          backtrace_line(caller_info.to_s.split(':in `block').first)
        end

        def dump_backtrace(example)
          format_backtrace(example.execution_result[:exception].backtrace, example).each do |backtrace_info|
            output.puts detail_color("#{long_padding}# #{backtrace_info}")
          end
        end

        def dump_pending_fixed(example, index)
          output.puts "#{short_padding}#{index.next}) #{example.full_description} FIXED"
          output.puts fixed_color("#{long_padding}Expected pending '#{example.metadata[:execution_result][:pending_message]}' to fail. No Error was raised.")
        end

        def pending_fixed?(example)
          example.execution_result[:exception].pending_fixed?
        end

        def dump_failure(example, index)
          output.puts "#{short_padding}#{index.next}) #{example.full_description}"
          dump_failure_info(example)
        end

        def dump_failure_info(example)
          exception = example.execution_result[:exception]
          exception_class_name = exception_class_name_for(exception)
          output.puts "#{long_padding}#{failure_color("Failure/Error:")} #{failure_color(read_failed_line(exception, example).strip)}"
          output.puts "#{long_padding}#{failure_color(exception_class_name)}:" unless exception_class_name =~ /RSpec/
          exception.message.to_s.split("\n").each { |line| output.puts "#{long_padding}  #{failure_color(line)}" } if exception.message

          if shared_group = find_shared_group(example)
            dump_shared_failure_info(shared_group)
          end
        end

        def exception_class_name_for(exception)
          name = exception.class.name.to_s
          name ="(anonymous error class)" if name == ''
          name
        end

        def dump_shared_failure_info(group)
          output.puts "#{long_padding}Shared Example Group: \"#{group.metadata[:shared_group_name]}\" called from " +
            "#{backtrace_line(group.metadata[:example_group][:location])}"
        end

        def find_shared_group(example)
          group_and_parent_groups(example).find {|group| group.metadata[:shared_group_name]}
        end

        def group_and_parent_groups(example)
          example.example_group.parent_groups + [example.example_group]
        end
      end
    end
  end
end
