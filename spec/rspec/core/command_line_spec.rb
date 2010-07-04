require "spec_helper"
require "stringio"

module RSpec::Core
  describe CommandLine do
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
        CommandLine.new(config_options, config)
      end

      let(:config) do
        RSpec::Core::Configuration.new
      end

      let(:out) { ::StringIO.new }

      before do
        config.stub(:run_hook)
      end

      it "runs before suite hooks" do
        config.should_receive(:run_hook).with(:before, :suite)
        command_line.run(out, out)
      end

      it "runs after suite hooks" do
        config.should_receive(:run_hook).with(:after, :suite)
        command_line.run(out, out)
      end

      it "runs after suite hooks even after an error" do
        after_suite_called = false
        config.stub(:run_hook) do |*args|
          case args.first
          when :before
            raise "this error"
          when :after
            after_suite_called = true
          end
        end
        expect do
          command_line.run(out, out)
        end.to raise_error
        after_suite_called.should be_true
      end
    end

  end
end
