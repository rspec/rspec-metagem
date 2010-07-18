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
  end
end
