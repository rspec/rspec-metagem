RSpec::Support.require_rspec_core "bisect/subset_enumerator"

module RSpec
  module Core
    module Bisect
      # @private
      # Contains the core bisect logic. Searches for examples we can ignore by
      # repeatedly running different subsets of the suite.
      class ExampleMinimizer
        attr_reader :runner, :all_example_ids_in_execution_order, :failed_example_ids

        def initialize(runner)
          @runner = runner
          @all_example_ids_in_execution_order = runner.original_results.all_example_ids_in_execution_order
          @failed_example_ids = runner.original_results.failed_example_ids
        end

        def find_minimal_repro
          remaining_ids = all_example_ids_in_execution_order - failed_example_ids
          debug 0, "Initial failed_example_ids: #{failed_example_ids}"
          debug 0, "Initial remaining_ids: #{remaining_ids}"

          loop do
            ids_to_ignore = SubsetEnumerator.new(remaining_ids).find do |ids|
              get_same_failures?(remaining_ids - ids)
            end

            break unless ids_to_ignore
            remaining_ids -= ids_to_ignore
            debug 1, "Removed #{ids_to_ignore}; remaining_ids: #{remaining_ids}"
          end

          remaining_ids + failed_example_ids
        end

      private

        def get_same_failures?(ids)
          results = runner.run(ids + failed_example_ids)
          (results.failed_example_ids == failed_example_ids).tap do |same|
            if same
              debug 2, "Running with #{ids}, got same failures"
            else
              debug 2, "Running with #{ids}, got different failures: #{results.failed_example_ids}"
            end
          end
        end

        def debug(level, msg)
          puts "#{'  ' * level}Minimizer: #{msg}" if ENV['DEBUG_RSPEC_BISECT']
        end
      end
    end
  end
end
