require 'rspec/core/bisect/runner'
require 'rspec/core/formatters/bisect_formatter'

module RSpec::Core
  RSpec.describe Bisect::Runner do
    let(:server) { instance_double("RSpec::Core::Bisect::Server", :drb_port => 1234) }
    let(:runner) { described_class.new(server, original_cli_args) }

    describe "#run" do
      let(:original_cli_args) { %w[ spec/1_spec.rb ] }

      it "passes the failed examples from the original run as the expected failures so the runs can abort early" do
        original_results = Formatters::BisectFormatter::RunResults.new(
          [], %w[ spec/failure_spec.rb[1:1] spec/failure_spec.rb[1:2] ]
        )

        expect(server).to receive(:capture_run_results).
          with(no_args).
          ordered.
          and_return(original_results)

        expect(server).to receive(:capture_run_results).
          with(original_results.failed_example_ids).
          ordered

        runner.run(%w[ spec/1_spec.rb[1:1] spec/1_spec.rb[1:2] ])
      end

      it 'ensures environment variables are propagated to the spawned process', :slow do
        output = nil
        allow(server).to receive(:capture_run_results) do |&block|
          output = block.call
          Formatters::BisectFormatter::RunResults.new([], [])
        end

        with_env_vars 'MY_ENV_VAR' => 'secret' do
          runner.run(%w[ spec/rspec/core/resources/echo_env_var.rb ])
        end

        expect(output).to include("MY_ENV_VAR=secret")
      end
    end

    describe "#command_for" do
      def command_for(locations, options={})
        load_path = options.fetch(:load_path) { [] }
        orig_load_path = $LOAD_PATH.dup
        $LOAD_PATH.replace(load_path)
        runner.command_for(locations)
      ensure
        $LOAD_PATH.replace(orig_load_path)
      end

      let(:original_cli_args) { %w[ spec/unit -rfoo -Ibar --warnings --backtrace ] }

      it "includes the original CLI arg options" do
        cmd = command_for(%w[ spec/1.rb spec/2.rb ])
        expect(cmd).to include("-rfoo -Ibar --warnings --backtrace")
      end

      it 'replaces the locations from the original CLI args with the provided locations' do
        cmd = command_for(%w[ spec/1.rb spec/2.rb ])
        expect(cmd).to match(%r{'?spec/1\.rb'? '?spec/2\.rb'?}).and exclude("spec/unit")
      end

      it 'escapes locations' do
        cmd = command_for(["path/with spaces/to/spec.rb"])
        if uses_quoting_for_escaping?
          expect(cmd).to include("'path/with spaces/to/spec.rb'")
        else
          expect(cmd).to include('path/with\ spaces/to/spec.rb')
        end
      end

      it "includes an option for the server's DRB port" do
        cmd = command_for([])
        expect(cmd).to include("--drb-port #{server.drb_port}")
      end

      it "ignores an existing --drb-port option (since we use the server's port instead)" do
        original_cli_args << "--drb-port" << "9999"
        cmd = command_for([])
        expect(cmd).to include("--drb-port #{server.drb_port}").and exclude("9999")
        expect(cmd.scan("--drb-port").count).to eq(1)
      end

      it 'ignores the `--bisect` option since that would infinitely recurse' do
        original_cli_args << "--bisect"
        cmd = command_for([])
        expect(cmd).to exclude("--bisect")
      end

      it 'uses the bisect formatter' do
        cmd = command_for([])
        expect(cmd).to include("--format bisect")
      end

      def expect_formatters_to_be_excluded
        cmd = command_for([])
        expect(cmd).to include("--format bisect").and exclude(
          "progress", "html", "--out", "specs.html", "-f ", "-o "
        )
        expect(cmd.scan("--format").count).to eq(1)
      end

      it 'excludes any --format and matching --out options passed in the original args' do
        original_cli_args.concat %w[ --format progress --format html --out specs.html ]
        expect_formatters_to_be_excluded
      end

      it 'excludes any -f <value> and matching -o <value> options passed in the original args' do
        original_cli_args.concat %w[ -f progress -f html -o specs.html ]
        expect_formatters_to_be_excluded
      end

      it 'excludes any -f<value> and matching -o<value> options passed in the original args' do
        original_cli_args.concat %w[ -fprogress -fhtml -ospecs.html ]
        expect_formatters_to_be_excluded
      end

      it 'starts with the path to the current ruby executable' do
        cmd = command_for([])
        expect(cmd).to start_with(File.join(
          RbConfig::CONFIG['bindir'],
          RbConfig::CONFIG['ruby_install_name']
        ))
      end

      it 'includes the path to the rspec executable after the ruby executable' do
        cmd = command_for([])
        expect(cmd).to first_include("ruby").then_include(RSpec::Core.path_to_executable)
      end

      it 'escapes the rspec executable' do
        allow(RSpec::Core).to receive(:path_to_executable).and_return("path/with spaces/rspec")
        cmd = command_for([])

        if uses_quoting_for_escaping?
          expect(cmd).to include("'path/with spaces/rspec'")
        else
          expect(cmd).to include('path/with\ spaces/rspec')
        end
      end

      it 'includes the current load path as an option to `ruby`, not as an option to `rspec`' do
        cmd = command_for([], :load_path => %W[ lp/foo lp/bar ])
        if uses_quoting_for_escaping?
          expect(cmd).to first_include("-I'lp/foo':'lp/bar'").then_include(RSpec::Core.path_to_executable)
        else
          expect(cmd).to first_include("-Ilp/foo:lp/bar").then_include(RSpec::Core.path_to_executable)
        end
      end

      it 'escapes the load path entries' do
        cmd = command_for([], :load_path => ['l p/foo', 'l p/bar' ])
        if uses_quoting_for_escaping?
          expect(cmd).to first_include("-I'l p/foo':'l p/bar'").then_include(RSpec::Core.path_to_executable)
        else
          expect(cmd).to first_include('-Il\ p/foo:l\ p/bar').then_include(RSpec::Core.path_to_executable)
        end
      end
    end

    describe "#repro_command_from", :simulate_shell_allowing_unquoted_ids do
      let(:original_cli_args) { %w[ spec/unit --seed 1234 ] }

      def repro_command_from(ids)
        runner.repro_command_from(ids)
      end

      it 'starts with `rspec #{example_ids}`' do
        cmd = repro_command_from(%w[ ./spec/unit/1_spec.rb[1:1] ./spec/unit/2_spec.rb[1:1] ])
        expect(cmd).to start_with("rspec ./spec/unit/1_spec.rb[1:1] ./spec/unit/2_spec.rb[1:1]")
      end

      it 'includes the original CLI args but excludes the original CLI locations' do
        cmd = repro_command_from(%w[ ./spec/unit/1_spec.rb[1:1] ./spec/unit/2_spec.rb[1:1] ])
        expect(cmd).to include("--seed 1234").and exclude("spec/unit ")
      end

      it 'includes original options that `command_for` excludes' do
        original_cli_args << "--format" << "progress"
        expect(runner.command_for(%w[ ./foo.rb[1:1] ])).to exclude("--format progress")
        expect(repro_command_from(%w[ ./foo.rb[1:1] ])).to include("--format progress")
      end

      it 'groups multiple ids for the same file together' do
        cmd = repro_command_from(%w[ ./spec/unit/1_spec.rb[1:1] ./spec/unit/1_spec.rb[1:2] ])
        expect(cmd).to include("./spec/unit/1_spec.rb[1:1,1:2]")
      end

      it 'prints the files in alphabetical order' do
        cmd = repro_command_from(%w[ ./spec/unit/2_spec.rb[1:1] ./spec/unit/1_spec.rb[1:1] ])
        expect(cmd).to include("./spec/unit/1_spec.rb[1:1] ./spec/unit/2_spec.rb[1:1]")
      end

      it 'prints ids from the same file in sequential order' do
        cmd = repro_command_from(%w[
          ./spec/unit/1_spec.rb[2:1]
          ./spec/unit/1_spec.rb[1:2]
          ./spec/unit/1_spec.rb[1:1]
          ./spec/unit/1_spec.rb[1:10]
          ./spec/unit/1_spec.rb[1:9]
        ])

        expect(cmd).to include("./spec/unit/1_spec.rb[1:1,1:2,1:9,1:10,2:1]")
      end

      it 'does not include `--bisect` even though the original args do' do
        original_cli_args << "--bisect"
        expect(repro_command_from(%w[ ./foo.rb[1:1] ])).to exclude("bisect")
      end

      it 'quotes the ids on a shell like ZSH that requires it' do
        with_env_vars 'SHELL' => '/usr/local/bin/zsh' do
          expect(repro_command_from(%w[ ./foo.rb[1:1] ])).to include("'./foo.rb[1:1]'")
        end
      end
    end

    describe "#original_results" do
      let(:original_cli_args) { %w[spec/unit] }

      open3_method = Open3.respond_to?(:capture2e) ? :capture2e : :popen3
      open3_method = :popen3 if RSpec::Support::Ruby.jruby?

      before do
        allow(Open3).to receive(open3_method).and_return(
          [double("Exit Status"), double("Stdout/err")]
        )
        allow(server).to receive(:capture_run_results) do |&block|
          block.call
          "the results"
        end
      end

      it "runs the suite with the locations from the original CLI args" do
        runner.original_results
        expect(Open3).to have_received(open3_method).with(a_string_including("spec/unit"))
      end

      it 'returns the run results' do
        expect(runner.original_results).to eq("the results")
      end

      it 'memoizes, since it is expensive to re-run the suite' do
        expect(runner.original_results).to be(runner.original_results)
      end
    end

    def uses_quoting_for_escaping?
      RSpec::Support::OS.windows? || RSpec::Support::Ruby.jruby?
    end
  end
end
