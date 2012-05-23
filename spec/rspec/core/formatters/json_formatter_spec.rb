require 'spec_helper'
require 'rspec/core/formatters/json_formatter'
require 'json'
require 'rspec/core/reporter'

# todo, someday:
# it "lists the groups (describe and context) separately"
# it "includes full 'execution_result'"
# it "relativizes backtrace paths"
# it "includes profile information (implements dump_profile)"
# it "shows the pending message if one was given"
# it "shows the seed if run was randomized"
# it "lists pending specs that were fixed"
describe RSpec::Core::Formatters::JsonFormatter do
  let(:output) { StringIO.new }
  let(:formatter) { RSpec::Core::Formatters::JsonFormatter.new(output) }
  let(:reporter) { RSpec::Core::Reporter.new(formatter) }

  it "outputs json (brittle high level functional test)" do
    group = RSpec::Core::ExampleGroup.describe("one apiece") do
      it("succeeds") { 1.should == 1 }
      it("fails") { fail "eek" }
      it("pends") { pending "world peace" }
    end
    succeeding_line = __LINE__ - 4
    failing_line = __LINE__ - 4
    pending_line = __LINE__ - 4

    now = Time.now
    Time.stub(:now).and_return(now)
    reporter.report(2) do |r|
      group.run(r)
    end

    # grab the actual backtrace -- kind of a cheat
    failing_backtrace = formatter.output_hash[:examples][1][:exception][:backtrace]
    this_file = relative_path(__FILE__)

    expected = {
      :examples => [
        {
          :description => "succeeds",
          :full_description => "one apiece succeeds",
          :status => "passed",
          :file_path => this_file,
          :line_number => succeeding_line,
        },
        {
          :description => "fails",
          :full_description => "one apiece fails",
          :status => "failed",
          :file_path => this_file,
          :line_number => failing_line,
          :exception => {:class => "RuntimeError", :message => "eek", :backtrace => failing_backtrace}
        },
        {
          :description => "pends",
          :full_description => "one apiece pends",
          :status => "pending",
          :file_path => this_file,
          :line_number => pending_line,
        },
      ],
      :summary => {
        :duration => formatter.output_hash[:summary][:duration],
        :example_count => 3,
        :failure_count => 1,
        :pending_count => 1,
      },
      :summary_line => "3 examples, 1 failure, 1 pending"
    }
    formatter.output_hash.should == expected
    output.string.should == expected.to_json
  end

  describe "#stop" do
    it "adds all examples to the output hash" do
      formatter.stop
      formatter.output_hash[:examples].should_not be_nil
    end
  end

  describe "#close" do
    it "outputs the results as a JSON string" do
      output.string.should == ""
      formatter.close
      output.string.should == {}.to_json
    end
  end

  describe "#message" do
    it "adds a message to the messages list" do
      formatter.message("good job")
      formatter.output_hash[:messages].should == ["good job"]
    end
  end

  describe "#dump_summary" do
    it "adds summary info to the output hash" do
      duration, example_count, failure_count, pending_count = 1.0, 2, 1, 1
      formatter.dump_summary(duration, example_count, failure_count, pending_count)
      summary = formatter.output_hash[:summary]
      %w(duration example_count failure_count pending_count).each do |key|
        summary[key.to_sym].should == eval(key)
      end
      summary_line = formatter.output_hash[:summary_line]
      summary_line.should == "2 examples, 1 failure, 1 pending"
    end
  end
end
