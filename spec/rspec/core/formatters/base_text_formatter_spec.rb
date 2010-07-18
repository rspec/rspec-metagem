require "spec_helper"

module RSpec::Core::Formatters

  describe BaseTextFormatter do
    describe "#summary_line" do
      let(:output) { StringIO.new }
      let(:formatter) { RSpec::Core::Formatters::BaseTextFormatter.new(output) }

      context "with 0s" do
        it "outputs pluralized (excluding pending)" do
          formatter.summary_line(0,0,0).should eq("0 examples, 0 failures")
        end
      end

      context "with 1s" do
        it "outputs singular (including pending)" do
          formatter.summary_line(1,1,1).should eq("1 example, 1 failure, 1 pending")
        end
      end

      context "with 2s" do
        it "outputs pluralized (including pending)" do
          formatter.summary_line(2,2,2).should eq("2 examples, 2 failures, 2 pending")
        end
      end
    end

    describe "#dump_failures" do
      it "preserves formatting" do
        output = StringIO.new
        group = RSpec::Core::ExampleGroup.describe("group name")
        example = group.example("example name") { "this".should eq("that") }
        formatter = RSpec::Core::Formatters::BaseTextFormatter.new(output)
        group.run_all(formatter)

        RSpec.configuration.stub(:color_enabled?) { false }
        formatter.dump_failures
        output.string.should =~ /group name example name/m
        output.string.should =~ /(\s+)expected \"that\"\n\1     got \"this\"/m
      end
    end
  end
end
