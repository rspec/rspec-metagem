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
RSpec.describe RSpec::Core::Formatters::JsonFormatter do
  let(:output) { StringIO.new }
  let(:formatter) { RSpec::Core::Formatters::JsonFormatter.new(output) }
  let(:config) { RSpec::Core::Configuration.new }
  let(:reporter) { RSpec::Core::Reporter.new(config).tap { |reporter| formatter.setup reporter } }

  it "outputs json (brittle high level functional test)" do
    group = RSpec::Core::ExampleGroup.describe("one apiece") do
      it("succeeds") { expect(1).to eq 1 }
      it("fails") { fail "eek" }
      it("pends") { pending "world peace" }
    end
    succeeding_line = __LINE__ - 4
    failing_line = __LINE__ - 4
    pending_line = __LINE__ - 4

    now = Time.now
    allow(Time).to receive(:now).and_return(now)
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
          :run_time => formatter.output_hash[:examples][0][:run_time]
        },
        {
          :description => "fails",
          :full_description => "one apiece fails",
          :status => "failed",
          :file_path => this_file,
          :line_number => failing_line,
          :run_time => formatter.output_hash[:examples][1][:run_time],
          :exception => {:class => "RuntimeError", :message => "eek", :backtrace => failing_backtrace}
        },
        {
          :description => "pends",
          :full_description => "one apiece pends",
          :status => "pending",
          :file_path => this_file,
          :line_number => pending_line,
          :run_time => formatter.output_hash[:examples][2][:run_time]
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
    expect(formatter.output_hash).to eq expected
    expect(output.string).to eq expected.to_json
  end

  describe "#stop" do
    it "adds all examples to the output hash" do
      formatter.stop
      expect(formatter.output_hash[:examples]).not_to be_nil
    end
  end

  describe "#close" do
    it "outputs the results as a JSON string" do
      expect(output.string).to eq ""
      formatter.close
      expect(output.string).to eq({}.to_json)
    end
  end

  describe "#message" do
    it "adds a message to the messages list" do
      formatter.message("good job")
      expect(formatter.output_hash[:messages]).to eq ["good job"]
    end
  end

  describe "#dump_summary" do
    it "adds summary info to the output hash" do
      values = { :duration => 1.0, :example_count => 2, :failure_count => 1, :pending_count => 1 }
      formatter.dump_summary(values[:duration], values[:example_count], values[:failure_count], values[:pending_count])
      summary = formatter.output_hash[:summary]
      values.each do |key,value|
        expect(summary[key]).to eq value
      end
      summary_line = formatter.output_hash[:summary_line]
      expect(summary_line).to eq "2 examples, 1 failure, 1 pending"
    end
  end

  describe "#dump_profile_slowest_examples" do

    before do
      group = RSpec::Core::ExampleGroup.describe("group") do
        # Use a sleep so there is some measurable time, to ensure
        # the reported percent is 100%, not 0%.
        example("example") { sleep 0.001 }
      end
      group.run(double('reporter').as_null_object)

      allow(formatter).to receive(:examples) { group.examples }
      allow(RSpec.configuration).to receive(:profile_examples) { 10 }
    end

    it "names the example" do
      formatter.dump_profile_slowest_examples
      expect(formatter.output_hash[:profile][:examples].first[:full_description]).to eq("group example")
    end

    it "provides example execution time" do
      formatter.dump_profile_slowest_examples
      expect(formatter.output_hash[:profile][:examples].first[:run_time]).not_to be_nil
    end

    it "has the summary of profile information" do
      formatter.dump_profile_slowest_examples
      expect(formatter.output_hash[:profile].keys).to match_array([:examples, :slowest, :total])
    end
  end

  describe "#dump_profile_slowest_example_groups" do
    let(:group) do
      RSpec::Core::ExampleGroup.describe("slow group") do
        # Use a sleep so there is some measurable time, to ensure
        # the reported percent is 100%, not 0%.
        example("example") { sleep 0.01 }
      end
    end
    let(:rpt) { double('reporter').as_null_object }

    before do
      allow(RSpec.configuration).to receive(:profile_examples) { 10 }
      group.run(rpt)
    end

    context "with one example group" do
      before { allow(formatter).to receive(:examples) { group.examples } }

      it "doesn't profile a single example group" do
        formatter.dump_profile_slowest_example_groups
        expect(formatter.output_hash[:profile][:groups]).to be_empty
      end
    end

    context "with multiple example groups" do
      before do
        group2 = RSpec::Core::ExampleGroup.describe("fast group") do
          example("example 1") { sleep 0.004 }
          example("example 2") { sleep 0.007 }
        end
        group2.run(rpt)

        allow(formatter).to receive(:examples) { group.examples + group2.examples }
      end

      it "provides the slowest example groups" do
        formatter.dump_profile_slowest_example_groups
        expect(formatter.output_hash).not_to be_empty
      end

      it "provides information" do
        formatter.dump_profile_slowest_example_groups
        expect(formatter.output_hash[:profile][:groups].first.keys).to match_array([:total_time, :count, :description, :average, :location])
      end

      it "ranks the example groups by average time" do
        formatter.dump_profile_slowest_example_groups
        expect(formatter.output_hash[:profile][:groups].first[:description]).to eq("slow group")
      end
    end

    it "depends on parent_groups to get the top level example group" do
      ex = ""
      group.describe("group 2") do
        describe "group 3" do
          ex = example("nested example 1")
        end
      end

      expect(ex.example_group.parent_groups.last).to eq(group)
    end
  end
end
