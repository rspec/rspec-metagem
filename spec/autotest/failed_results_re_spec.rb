require "spec_helper"

describe "failed_results_re for autotest" do
  let(:output) { StringIO.new }
  let(:formatter) { RSpec::Core::Formatters::BaseTextFormatter.new(output) }
  let(:example_output) do
    group = RSpec::Core::ExampleGroup.describe("group name")
    example = group.example("example name") { "this".should eq("that") }
    group.run_all(formatter)
    RSpec.configuration.stub(:color_enabled?) { false }
    formatter.dump_failures
    output.string
  end
  
  it "should match a failure" do
    re = Autotest::Rspec2.new.failed_results_re
    re =~ example_output
    $1.should == "group name example name\n     Failure/Error: example = group.example(\"example name\") { \"this\".should eq(\"that\") }"
    $2.should == __FILE__.sub(File.expand_path('.'),'.')
  end
end
