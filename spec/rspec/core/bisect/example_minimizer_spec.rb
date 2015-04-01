require 'rspec/core/bisect/example_minimizer'
require 'rspec/core/formatters/bisect_formatter'
require 'rspec/core/bisect/server'

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
        "rspec #{locations.sort.join(' ')}"
      end
    end

    it 'repeatedly runs various subsets of the suite, removing examples that have no effect on the failing examples' do
      minimizer = Bisect::ExampleMinimizer.new(FakeRunner.new(
        %w[ ex_1 ex_2 ex_3 ex_4 ex_5 ex_6 ex_7 ex_8 ],
        %w[ ex_2 ],
        { "ex_5" => "ex_4" }
      ), RSpec::Core::NullReporter)

      minimizer.find_minimal_repro
      expect(minimizer.repro_command_for_currently_needed_ids).to eq("rspec ex_2 ex_4 ex_5")
    end

    it 'aborts early when no examples fail' do
      minimizer = Bisect::ExampleMinimizer.new(FakeRunner.new(
        %w[ ex_1 ex_2 ], [],  {}
      ), RSpec::Core::NullReporter)

      expect {
        minimizer.find_minimal_repro
      }.to raise_error(RSpec::Core::Bisect::BisectFailedError, /No failures found/i)
    end

    context "when the `repro_command_for_currently_needed_ids` is queried before it has sufficient information" do
      it 'returns an explanation that will be printed when the bisect run is aborted immediately' do
        minimizer = Bisect::ExampleMinimizer.new(FakeRunner.new([], [], {}), RSpec::Core::NullReporter)
        expect(minimizer.repro_command_for_currently_needed_ids).to include("Not yet enough information")
      end
    end
  end
end
