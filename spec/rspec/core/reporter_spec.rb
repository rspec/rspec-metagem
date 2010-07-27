require "spec_helper"

module RSpec::Core
  describe Reporter do
    context "given one formatter" do
      it "passes messages to that formatter" do
        formatter = double("formatter")
        example = double("example")
        reporter = Reporter.new(formatter)

        formatter.should_receive(:example_started).
          with(example)

        reporter.example_started(example)
      end
    end

    context "given multiple formatters" do
      it "passes messages to all formatters" do
        formatters = [double("formatter"), double("formatter")]
        example = double("example")
        reporter = Reporter.new(*formatters)

        formatters.each do |formatter|
          formatter.
            should_receive(:example_started).
            with(example)
        end

        reporter.example_started(example)
      end
    end
  end
end
