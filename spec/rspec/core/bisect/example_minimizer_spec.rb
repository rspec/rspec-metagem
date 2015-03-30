require 'rspec/core/bisect/example_minimizer'
require 'rspec/core/formatters/bisect_formatter'

module RSpec::Core
  RSpec.describe Bisect::ExampleMinimizer do
    RunResults = Formatters::BisectFormatter::RunResults

    FakeRunner = Struct.new(:all_ids, :always_failures, :dependent_failures) do
      def original_cli_args
        []
      end

      def original_results
        failures = always_failures | dependent_failures.keys
        RunResults.new(all_ids, failures.sort)
      end

      def run(ids)
        failures = ids & always_failures
        dependent_failures.each do |failing_example, depends_upon|
          failures << failing_example if ids.include?(depends_upon)
        end

        RunResults.new(ids.sort, failures.sort)
      end

      def repro_command_from(locations)
        ""
      end
    end

    it 'repeatedly runs various subsets of the suite, removing examples that have no effect on the failing examples' do
      minimizer = Bisect::ExampleMinimizer.new(FakeRunner.new(
        %w[ ex_1 ex_2 ex_3 ex_4 ex_5 ex_6 ex_7 ex_8 ],
        %w[ ex_2 ],
        { "ex_5" => "ex_4" }
      ), RSpec::Core::NullReporter)

      ids = minimizer.find_minimal_repro
      expect(ids).to match_array(%w[ ex_2 ex_4 ex_5 ])
    end
  end
end
