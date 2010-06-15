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
  end
end
