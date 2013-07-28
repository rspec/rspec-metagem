require 'spec_helper'
require 'rspec/core/formatters/documentation_formatter'

module RSpec::Core::Formatters
  RSpec.describe DocumentationFormatter do
    let(:output)    { StringIO.new }
    let(:config)    { RSpec::Core::Configuration.new }
    let(:reporter)  { RSpec::Core::Reporter.new(config) }
    let(:formatter) { RSpec::Core::Formatters::DocumentationFormatter.new(output) }

    before do
      reporter.register_listener formatter, *formatter.notifications
      allow(config).to receive(:color_enabled?) { false }
    end

    it "lists its additional notifications" do
      expect(formatter.notifications).to include(
        :example_group_started, :example_group_finished, :example_passed,
        :example_failed
       )
    end

    it "numbers the failures" do
      examples = [
        double("example 1",
               :description => "first example",
               :execution_result => {:status => 'failed', :exception => Exception.new }
              ),
        double("example 2",
               :description => "second example",
               :execution_result => {:status => 'failed', :exception => Exception.new }
              )
      ]
      examples.each {|e| formatter.example_failed(e) }

      expect(output.string).to match(/first example \(FAILED - 1\)/m)
      expect(output.string).to match(/second example \(FAILED - 2\)/m)
    end

    it "represents nested group using hierarchy tree" do
      group = RSpec::Core::ExampleGroup.describe("root")
      context1 = group.describe("context 1")
      context1.example("nested example 1.1"){}
      context1.example("nested example 1.2"){}

      context11 = context1.describe("context 1.1")
      context11.example("nested example 1.1.1"){}
      context11.example("nested example 1.1.2"){}

      context2 = group.describe("context 2")
      context2.example("nested example 2.1"){}
      context2.example("nested example 2.2"){}

      group.run(reporter)

      expect(output.string).to eql("
root
  context 1
    nested example 1.1
    nested example 1.2
    context 1.1
      nested example 1.1.1
      nested example 1.1.2
  context 2
    nested example 2.1
    nested example 2.2
")
    end

    it "strips whitespace for each row" do
      group = RSpec::Core::ExampleGroup.describe(" root ")
      context1 = group.describe(" nested ")
      context1.example(" example 1 ") {}
      context1.example(" example 2 ", :pending => true){}
      context1.example(" example 3 ") { fail }

      group.run(reporter)

      expect(output.string).to eql("
root
  nested
    example 1
    example 2 (PENDING: No reason given)
    example 3 (FAILED - 1)
")
    end
  end
end
