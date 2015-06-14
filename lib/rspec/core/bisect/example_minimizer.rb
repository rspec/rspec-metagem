module RSpec
  module Core
    module Bisect
      # @private
      # Contains the core bisect logic. Searches for examples we can ignore by
      # repeatedly running different subsets of the suite.
      class ExampleMinimizer
        attr_reader :runner, :reporter, :all_example_ids, :failed_example_ids
        attr_accessor :remaining_ids

        def initialize(runner, reporter)
          @runner   = runner
          @reporter = reporter
        end

        def find_minimal_repro
          prep

          _, duration = track_duration do
            bisect(non_failing_example_ids)
          end

          notify(:bisect_complete, :round => 10, :duration => duration,
                                   :original_non_failing_count => non_failing_example_ids.size,
                                   :remaining_count => remaining_ids.size)

          remaining_ids + failed_example_ids
        end

        def bisect(candidate_ids)
          notify(:bisect_dependency_check_started)
          if get_expected_failures_for?([])
            notify(:bisect_dependency_check_failed)
            self.remaining_ids = []
            return
          end
          notify(:bisect_dependency_check_passed)

          bisect_over(candidate_ids)
        end

        def bisect_over(candidate_ids)
          return if candidate_ids.one?

          slice_size = (candidate_ids.length / 2.0).ceil
          lhs, rhs = candidate_ids.each_slice(slice_size).to_a

          notify(
            :bisect_round_started,
            :round => 10,
            :subset_size => slice_size,
            :remaining_count => candidate_ids.size
          )

          ids_to_ignore = [lhs, rhs].find do |ids|
            get_expected_failures_for?(remaining_ids - ids)
          end

          if ids_to_ignore
            self.remaining_ids -= ids_to_ignore
            notify(
              :bisect_ignoring_ids,
              :ids_to_ignore => ids_to_ignore,
              :remaining_ids => remaining_ids
            )
            bisect_over(candidate_ids - ids_to_ignore)
          else
            notify(
              :bisect_multiple_culprits_detected,
              :duration => duration
            )
            bisect_over(lhs)
            bisect_over(rhs)
          end
        end

        def currently_needed_ids
          remaining_ids + failed_example_ids
        end

        def repro_command_for_currently_needed_ids
          return runner.repro_command_from(currently_needed_ids) if remaining_ids
          "(Not yet enough information to provide any repro command)"
        end

      private

        def prep
          notify(:bisect_starting, :original_cli_args => runner.original_cli_args)

          _, duration = track_duration do
            original_results    = runner.original_results
            @all_example_ids    = original_results.all_example_ids
            @failed_example_ids = original_results.failed_example_ids
            @remaining_ids      = non_failing_example_ids
          end

          if @failed_example_ids.empty?
            raise BisectFailedError, "\n\nNo failures found. Bisect only works " \
                  "in the presence of one or more failing examples."
          else
            notify(:bisect_original_run_complete, :failed_example_ids => failed_example_ids,
                                                  :non_failing_example_ids => non_failing_example_ids,
                                                  :duration => duration)
          end
        end

        def non_failing_example_ids
          @non_failing_example_ids ||= all_example_ids - failed_example_ids
        end

        def get_expected_failures_for?(ids)
          ids_to_run = ids + failed_example_ids
          notify(
            :bisect_individual_run_start,
            :command => runner.repro_command_from(ids_to_run),
            :ids_to_run => ids_to_run
          )

          results, duration = track_duration { runner.run(ids_to_run) }
          notify(:bisect_individual_run_complete, :duration => duration, :results => results)

          abort_if_ordering_inconsistent(results)
          (failed_example_ids & results.failed_example_ids) == failed_example_ids
        end

        def track_duration
          start = ::RSpec::Core::Time.now
          [yield, ::RSpec::Core::Time.now - start]
        end

        def abort_if_ordering_inconsistent(results)
          expected_order = all_example_ids & results.all_example_ids
          return if expected_order == results.all_example_ids

          raise BisectFailedError, "\n\nThe example ordering is inconsistent. " \
                "`--bisect` relies upon consistent ordering (e.g. by passing " \
                "`--seed` if you're using random ordering) to work properly."
        end

        def notify(*args)
          reporter.publish(*args)
        end
      end
    end
  end
end
