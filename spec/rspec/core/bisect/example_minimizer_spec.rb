require 'rspec/core/bisect/example_minimizer'
require 'rspec/core/formatters/bisect_formatter'
require 'rspec/core/bisect/server'
require 'support/fake_bisect_runner'

module RSpec::Core
  RSpec.describe Bisect::ExampleMinimizer do
    let(:fake_runner) do
      FakeBisectRunner.new(
        %w[ ex_1 ex_2 ex_3 ex_4 ex_5 ex_6 ex_7 ex_8 ],
        %w[ ex_2 ],
        { "ex_5" => %w[ ex_4 ] }
      )
    end

    it 'repeatedly runs various subsets of the suite, removing examples that have no effect on the failing examples' do
      minimizer = Bisect::ExampleMinimizer.new(fake_runner, RSpec::Core::NullReporter)
      minimizer.find_minimal_repro
      expect(minimizer.repro_command_for_currently_needed_ids).to eq("rspec ex_2 ex_4 ex_5")
    end

    it 'ignores flapping examples that did not fail on the initial full run but fail on later runs' do
      def fake_runner.run(ids)
        super.tap do |results|
          @run_count ||= 0
          if (@run_count += 1) > 1
            results.failed_example_ids << "ex_8"
          end
        end
      end

      minimizer = Bisect::ExampleMinimizer.new(fake_runner, RSpec::Core::NullReporter)
      minimizer.find_minimal_repro
      expect(minimizer.repro_command_for_currently_needed_ids).to eq("rspec ex_2 ex_4 ex_5")
    end

    it 'aborts early when no examples fail' do
      minimizer = Bisect::ExampleMinimizer.new(FakeBisectRunner.new(
        %w[ ex_1 ex_2 ], [],  {}
      ), RSpec::Core::NullReporter)

      expect {
        minimizer.find_minimal_repro
      }.to raise_error(RSpec::Core::Bisect::BisectFailedError, /No failures found/i)
    end

    context "when the `repro_command_for_currently_needed_ids` is queried before it has sufficient information" do
      it 'returns an explanation that will be printed when the bisect run is aborted immediately' do
        minimizer = Bisect::ExampleMinimizer.new(FakeBisectRunner.new([], [], {}), RSpec::Core::NullReporter)
        expect(minimizer.repro_command_for_currently_needed_ids).to include("Not yet enough information")
      end
    end
  end
end
