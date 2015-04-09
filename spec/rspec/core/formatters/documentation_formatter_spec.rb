require 'rspec/core/formatters/documentation_formatter'

module RSpec::Core::Formatters
  RSpec.describe DocumentationFormatter do
    include FormatterSupport

    before do
      send_notification :start, start_notification(2)
      allow(formatter).to receive(:color_enabled?).and_return(false)
    end

    def execution_result(values)
      RSpec::Core::Example::ExecutionResult.new.tap do |er|
        values.each { |name, value| er.__send__(:"#{name}=", value) }
      end
    end

    it "numbers the failures" do
      send_notification :example_failed, example_notification( double("example 1",
               :description => "first example",
               :execution_result => execution_result(:status => :failed, :exception => Exception.new)
              ))
      send_notification :example_failed, example_notification( double("example 2",
               :description => "second example",
               :execution_result => execution_result(:status => :failed, :exception => Exception.new)
              ))

      expect(formatter_output.string).to match(/first example \(FAILED - 1\)/m)
      expect(formatter_output.string).to match(/second example \(FAILED - 2\)/m)
    end

    it "represents nested group using hierarchy tree" do
      group = RSpec.describe("root")
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

      expect(formatter_output.string).to eql("
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
      group = RSpec.describe(" root ")
      context1 = group.describe(" nested ")
      context1.example(" example 1 ") {}
      context1.example(" example 2 ", :pending => true){ fail }
      context1.example(" example 3 ") { fail }

      group.run(reporter)

      expect(formatter_output.string).to eql("
root
  nested
    example 1
    example 2 (PENDING: No reason given)
    example 3 (FAILED - 1)
")
    end

    # The backtrace is slightly different on JRuby/Rubinius so we skip there.
    it 'produces the expected full output', :if => RSpec::Support::Ruby.mri? do
      output = run_example_specs_with_formatter("doc")
      output.gsub!(/ +$/, '') # strip trailing whitespace

      expect(output).to eq(<<-EOS.gsub(/^\s+\|/, ''))
        |
        |pending spec with no implementation
        |  is pending (PENDING: Not yet implemented)
        |
        |pending command with block format
        |  with content that would fail
        |    is pending (PENDING: No reason given)
        |  with content that would pass
        |    fails (FAILED - 1)
        |
        |passing spec
        |  passes
        |
        |failing spec
        |  fails (FAILED - 2)
        |
        |a failing spec with odd backtraces
        |  fails with a backtrace that has no file (FAILED - 3)
        |  fails with a backtrace containing an erb file (FAILED - 4)
        |
        |#{expected_summary_output_for_example_specs}
      EOS
    end
  end
end
