require "spec_helper"

module RSpec::Core
  describe OptionParser do
    before do
      RSpec.stub(:deprecate)
    end

    it "deprecates the --formatter option" do
      RSpec.should_receive(:deprecate)
      Parser.parse!(%w[--formatter doc])
    end

    it "converts --formatter to --format" do
      options = Parser.parse!(%w[--formatter doc])
      options.should eq( {:formatter=>"doc"} )
    end

    it "does not parse empty args" do
      parser = Parser.new
      OptionParser.should_not_receive(:new)
      parser.parse!([])
    end

    it "parses output stream from --out" do
      options = Parser.parse!(%w[--out foo.txt])
      options.should eq( {:output_stream=>"foo.txt"} )
    end

    it "parses output stream from -o" do
      options = Parser.parse!(%w[-o foo.txt])
      options.should eq( {:output_stream=>"foo.txt"} )
    end
  end
end
