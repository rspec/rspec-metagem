module RSpec::Core
  RSpec.describe "Bisect", :slow, :simulate_shell_allowing_unquoted_ids do
    include FormatterSupport

    def bisect(cli_args)
      RSpec.configuration.output_stream = formatter_output
      parser = Parser.new(cli_args + ["--bisect"])
      expect(parser).to receive(:exit)

      expect {
        parser.parse
      }.to avoid_outputting.to_stdout_from_any_process.and avoid_outputting.to_stderr_from_any_process

      normalize_durations(formatter_output.string)
    end

    it 'finds the minimum rerun command and exits' do
      output = bisect(%w[spec/rspec/core/resources/order_dependent_specs.rb --order defined])

      expect(output).to eq(<<-EOS.gsub(/^\s+\|/, ''))
        |Bisect started using options: "spec/rspec/core/resources/order_dependent_specs.rb --order defined"
        |Running suite to find failures... (n.nnnn seconds)
        |Starting bisect with 1 failed example and 21 non-failing examples.
        |
        |Round 1: searching for 11 non-failing examples (of 21) to ignore: .. (n.nnnn seconds)
        |Round 2: searching for 6 non-failing examples (of 11) to ignore: . (n.nnnn seconds)
        |Round 3: searching for 3 non-failing examples (of 5) to ignore: . (n.nnnn seconds)
        |Round 4: searching for 1 non-failing example (of 2) to ignore: . (n.nnnn seconds)
        |Round 5: searching for 1 non-failing example (of 1) to ignore: . (n.nnnn seconds)
        |Bisect complete! Reduced necessary non-failing examples from 21 to 1 in n.nnnn seconds.
        |
        |The minimal reproduction command is:
        |  rspec ./spec/rspec/core/resources/order_dependent_specs.rb[11:1,22:1] --order defined
      EOS
    end

    context "when a load-time problem occurs while running the suite" do
      it 'surfaces the stdout and stderr output to the user' do
        output = bisect(%w[spec/rspec/core/resources/fail_on_load_spec.rb_])
        expect(output).to include("Bisect failed!", "undefined method `contex'", "About to call misspelled method")
      end
    end

    context "when the spec ordering is inconsistent" do
      it 'stops bisecting and surfaces the problem to the user' do
        output = bisect(%W[spec/rspec/core/resources/inconsistently_ordered_specs.rb])
        expect(output).to include("Bisect failed!", "The example ordering is inconsistent")
      end
    end
  end
end
