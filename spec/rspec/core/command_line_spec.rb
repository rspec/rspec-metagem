require "spec_helper"
require "stringio"
require 'tmpdir'

module RSpec::Core
  RSpec.describe CommandLine do

    let(:out)    { StringIO.new         }
    let(:err)    { StringIO.new         }
    let(:config) { RSpec::configuration }
    let(:world)  { RSpec::world         }

    before do
      allow(config.hooks).to receive(:run)
    end

    it "configures streams before command line options" do
      allow(RSpec).to receive(:deprecate)  # remove this and should_receive when ordered
      stdout = StringIO.new
      allow(config).to receive(:load_spec_files)
      allow(config).to receive(:reporter).and_return(double.as_null_object)
      config.output_stream = $stdout

      # this is necessary to ensure that color works correctly on windows
      expect(config).to receive(:error_stream=).ordered
      expect(config).to receive(:output_stream=).ordered
      expect(config).to receive(:force).at_least(:once).ordered

      command_line = build_command_line
      command_line.setup err, stdout
    end

    it "assigns submitted ConfigurationOptions to @options" do
      config_options = ConfigurationOptions.new(%w[--color])
      command_line   = CommandLine.new(config_options)
      expect(command_line.instance_exec { @options }).to be(config_options)
    end

    describe "#run" do
      context "delegation" do
        include_context "spec files"

        it "passes output streams to #setup" do
          command_line = build_command_line passing_spec_filename
          expect(command_line).to receive(:setup).with(err, out)
          command_line.run(err, out)
        end
        it "passes the example group list to #run_specs" do
          command_line = build_command_line passing_spec_filename
          expect(command_line).to receive(:run_specs).with(world.example_groups)
          command_line.run(err, out)
        end
      end

      context "running files" do
        include_context "spec files"

        it "returns 0 if spec passes" do
          command_line = build_command_line passing_spec_filename
          expect(command_line.run(err, out)).to eq 0
        end

        it "returns 1 if spec fails" do
          command_line = build_command_line failing_spec_filename
          expect(command_line.run(err, out)).to eq 1
        end

        it "returns 2 if spec fails and --failure-exit-code is 2" do
          command_line = build_command_line failing_spec_filename, "--failure-exit-code", "2"
          expect(command_line.run(err, out)).to eq 2
        end
      end

      context "running hooks" do
        before { allow(config).to receive :load_spec_files }

        it "runs before suite hooks" do
          expect(config.hooks).to receive(:run).with(:before, :suite, instance_of(SuiteHookContext))
          command_line = build_command_line
          command_line.run err, out
        end

        it "runs after suite hooks" do
          expect(config.hooks).to receive(:run).with(:after, :suite, instance_of(SuiteHookContext))
          command_line = build_command_line
          command_line.run err, out
        end

        it "runs after suite hooks even after an error" do
          expect(config.hooks).to receive(:run).with(:before, :suite, instance_of(SuiteHookContext)).and_raise "this error"
          expect(config.hooks).to receive(:run).with(:after , :suite, instance_of(SuiteHookContext))
          expect do
            command_line = build_command_line
            command_line.run err, out
          end.to raise_error("this error")
        end
      end
    end

    describe "#run with custom output" do
      before { allow(config).to receive_messages :files_to_run => [] }

      let(:output_file) { File.new("#{Dir.tmpdir}/command_line_spec_output.txt", 'w') }

      it "doesn't override output_stream" do
        config.output_stream = output_file
        command_line = build_command_line
        command_line.run err, nil
        expect(command_line.instance_exec { @configuration.output_stream }).to eq output_file
      end
    end

    def build_command_line *args
      CommandLine.new build_config_options(*args)
    end

    def build_config_options *args
      ConfigurationOptions.new args
    end
  end
end
