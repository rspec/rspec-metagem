require 'rspec/core/bisect/coordinator'
require 'support/fake_bisect_runner'
require 'support/formatter_support'

module RSpec::Core
  RSpec.describe Bisect::Coordinator, :simulate_shell_allowing_unquoted_ids do
    include FormatterSupport

    let(:fake_runner) do
      FakeBisectRunner.new(
        1.upto(8).map { |i| "#{i}.rb[1:1]" },
        %w[ 2.rb[1:1] ],
        { "5.rb[1:1]" => "4.rb[1:1]" }
      )
    end

    def find_minimal_repro(output)
      allow(Bisect::Server).to receive(:run).and_yield(instance_double(Bisect::Server))
      allow(Bisect::Runner).to receive(:new).and_return(fake_runner)

      RSpec.configuration.output_stream = output
      Bisect::Coordinator.bisect_with([], RSpec.configuration)
    ensure
      RSpec.reset # so that RSpec.configuration.output_stream isn't closed
    end

    it 'notifies the bisect progress formatter of progress and closes the output' do
      tempfile = Tempfile.new("bisect")
      output_file = File.open(tempfile.path, "w")
      expect { find_minimal_repro(output_file) }.to change(output_file, :closed?).from(false).to(true)
      output = normalize_durations(File.read(tempfile.path)).chomp

      expect(output).to eq(<<-EOS.gsub(/^\s+\|/, ''))
        |Bisect started using options: ""
        |Running suite to find failures... (n.nnnn seconds)
        |Starting bisect with 2 failing examples and 6 non-failing examples.
        |
        |Round 1: searching for 3 non-failing examples (of 6) to ignore: .. (n.nnnn seconds)
        |Round 2: searching for 2 non-failing examples (of 3) to ignore: . (n.nnnn seconds)
        |Round 3: searching for 1 non-failing example (of 1) to ignore: . (n.nnnn seconds)
        |Bisect complete! Reduced necessary non-failing examples from 6 to 1 in n.nnnn seconds.
        |
        |The minimal reproduction command is:
        |  rspec 2.rb[1:1] 4.rb[1:1] 5.rb[1:1]
      EOS
    end

    it 'can use the bisect debug formatter to get detailed progress' do
      output = StringIO.new
      with_env_vars('DEBUG_RSPEC_BISECT' => '1') { find_minimal_repro(output) }
      output = normalize_durations(output.string)

      expect(output).to eq(<<-EOS.gsub(/^\s+\|/, ''))
        |Bisect started using options: ""
        |Running suite to find failures... (n.nnnn seconds)
        | - Failing examples (2):
        |    - 2.rb[1:1]
        |    - 5.rb[1:1]
        | - Non-failing examples (6):
        |    - 1.rb[1:1]
        |    - 3.rb[1:1]
        |    - 4.rb[1:1]
        |    - 6.rb[1:1]
        |    - 7.rb[1:1]
        |    - 8.rb[1:1]
        |
        |Round 1: searching for 3 non-failing examples (of 6) to ignore:
        | - Running: rspec 2.rb[1:1] 5.rb[1:1] 6.rb[1:1] 7.rb[1:1] 8.rb[1:1] (n.nnnn seconds)
        | - Running: rspec 1.rb[1:1] 2.rb[1:1] 3.rb[1:1] 4.rb[1:1] 5.rb[1:1] (n.nnnn seconds)
        | - Examples we can safely ignore (3):
        |    - 6.rb[1:1]
        |    - 7.rb[1:1]
        |    - 8.rb[1:1]
        | - Remaining non-failing examples (3):
        |    - 1.rb[1:1]
        |    - 3.rb[1:1]
        |    - 4.rb[1:1]
        | - Round finished (n.nnnn seconds)
        |Round 2: searching for 2 non-failing examples (of 3) to ignore:
        | - Running: rspec 2.rb[1:1] 4.rb[1:1] 5.rb[1:1] (n.nnnn seconds)
        | - Examples we can safely ignore (2):
        |    - 1.rb[1:1]
        |    - 3.rb[1:1]
        | - Remaining non-failing examples (1):
        |    - 4.rb[1:1]
        | - Round finished (n.nnnn seconds)
        |Round 3: searching for 1 non-failing example (of 1) to ignore:
        | - Running: rspec 2.rb[1:1] 5.rb[1:1] (n.nnnn seconds)
        | - Round finished (n.nnnn seconds)
        |Bisect complete! Reduced necessary non-failing examples from 6 to 1 in n.nnnn seconds.
        |
        |The minimal reproduction command is:
        |  rspec 2.rb[1:1] 4.rb[1:1] 5.rb[1:1]
      EOS
    end

    context "when the user aborst the bisect with ctrl-c" do
      before do
        formatter_subclass = Class.new(Formatters::BisectProgressFormatter) do
          Formatters.register self

          def bisect_round_finished(notification)
            return super unless notification.round == 2

            Process.kill("INT", Process.pid)
            # Process.kill is not a synchronous call, so to ensure the output
            # below aborts at a deterministic place, we need to block here.
            # The sleep will be interrupted by the signal once the OS sends it.
            # For the most part, this is only needed on JRuby, but we saw
            # the asynchronous behavior on an MRI 2.0 travis build as well.
            sleep 5
          end
        end

        stub_const(Formatters::BisectProgressFormatter.name, formatter_subclass)
      end

      it "prints the most minimal repro command it has found so far" do
        output = StringIO.new
        expect {
          find_minimal_repro(output)
        }.to raise_error(an_object_having_attributes(
          :class  => SystemExit,
          :status => 1
        ))

        output = normalize_durations(output.string)

        expect(output).to eq(<<-EOS.gsub(/^\s+\|/, ''))
          |Bisect started using options: ""
          |Running suite to find failures... (n.nnnn seconds)
          |Starting bisect with 2 failing examples and 6 non-failing examples.
          |
          |Round 1: searching for 3 non-failing examples (of 6) to ignore: .. (n.nnnn seconds)
          |Round 2: searching for 2 non-failing examples (of 3) to ignore: .
          |
          |Bisect aborted!
          |
          |The most minimal reproduction command discovered so far is:
          |  rspec 2.rb[1:1] 4.rb[1:1] 5.rb[1:1]
        EOS
      end
    end
  end
end
