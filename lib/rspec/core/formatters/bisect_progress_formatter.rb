RSpec::Support.require_rspec_core "formatters/base_text_formatter"

module RSpec
  module Core
    module Formatters
      # @private
      # Produces progress output while bisecting.
      class BisectProgressFormatter < BaseTextFormatter
        Formatters.register self, :bisect_starting, :original_bisect_run_complete,
                            :bisect_round_started, :individual_run_complete,
                            :bisect_round_finished, :bisect_complete, :bisect_repro_command,
                            :bisect_failed

        def bisect_starting(notification)
          options = notification.original_cli_args.join(' ')
          output.puts "Bisect started using options: #{options.inspect}"
          output.print "Running suite to find failures..."
        end

        def original_bisect_run_complete(notification)
          failures     = Helpers.pluralize(notification.failures, "failed example")
          non_failures = Helpers.pluralize(notification.non_failures, "non-failing example")

          output.puts " (#{Helpers.format_duration(notification.duration)})"
          output.puts "Starting bisect with #{failures} and #{non_failures}."
        end

        def bisect_round_started(notification)
          search_desc = Helpers.pluralize(
            notification.subset_size, "non-failing example"
          )

          output.print "\nRound #{notification.round}: searching for #{search_desc}" \
                       " (of #{notification.remaining_count}) to ignore: "
        end

        def bisect_round_finished(notification)
          output.print " (#{Helpers.format_duration(notification.duration)})"
        end

        def individual_run_complete(_)
          output.print '.'
        end

        def bisect_complete(notification)
          output.puts "\nBisect complete! Reduced necessary non-failing examples " \
                      "from #{notification.original_non_failing_count} to " \
                      "#{notification.remaining_count} in " \
                      "#{Helpers.format_duration(notification.duration)}."
        end

        def bisect_repro_command(notification)
          output.puts "\nThe minimal reproduction command is:\n  #{notification.repro}"
        end

        def bisect_failed(notification)
          output.puts
          output.puts ConsoleCodes.wrap("Spec run failed!", :failure)
          output.puts
          output.puts ConsoleCodes.wrap(notification.run_output, :failure)
        end
      end
    end
  end
end
