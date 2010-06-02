require "spec_helper"

module RSpec::Core::Formatters

  describe BaseTextFormatter do
    describe "#dump_failures" do
      it "preserves formatting" do 
        output = StringIO.new
        group = RSpec::Core::ExampleGroup.describe
        example = group.example { "this".should eq("that") }
        formatter = RSpec::Core::Formatters::BaseTextFormatter.new(output)
        group.run_all(formatter)

        RSpec.configuration.stub(:color_enabled?) { false }
        formatter.dump_failures
        output.string.should =~ /(\s+)expected \"that\"\n\1     got \"this\"/m
      end
    end
  end
end
