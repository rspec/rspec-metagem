require "spec_helper"

module RSpec::Core
  describe CommandLine do
    context "given an array" do
      it "converts the contents to a ConfigurationOptions object" do
        command_line = CommandLine.new(%w[--color])
        command_line.instance_eval { @options }.should be_a(ConfigurationOptions)
      end
    end

    context "given a ConfigurationOptions object" do
      it "assigns it to @options" do
        config_options = ConfigurationOptions.new(%w[--color])
        config_options.parse_options
        command_line = CommandLine.new(config_options)
        command_line.instance_eval { @options }.should be(config_options)
      end
    end

    describe "#run" do
      let(:config_options) do
        config_options = ConfigurationOptions.new(%w[--color])
        config_options.parse_options
        config_options
      end

      let(:command_line) do
        CommandLine.new(config_options)
      end

      it "runs before suite hooks" do
        err = out = StringIO.new
        config = RSpec::Core::Configuration.new
        config.should_receive(:run_before_suite)
        command_line.stub(:configuration) { config }
        command_line.run(err, out)
      end

      it "runs after suite hooks" do
        err = out = StringIO.new
        config = RSpec::Core::Configuration.new
        config.should_receive(:run_after_suite)
        command_line.stub(:configuration) { config }
        command_line.run(err, out)
      end

      it "runs after suite hooks even after an error" do
        err = out = StringIO.new
        config = RSpec::Core::Configuration.new
        config.stub(:run_before_suite) { raise "this error" }
        config.should_receive(:run_after_suite)
        command_line.stub(:configuration) { config }
        expect do
          command_line.run(err, out)
        end.to raise_error
      end
    end

  end
end
