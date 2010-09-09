require 'spec_helper'

module RSpec::Core
  describe Runner do
    describe "#run" do
      context "with --drb or -X" do
        before(:each) do
          @err = @out = StringIO.new

          @options = RSpec::Core::ConfigurationOptions.new(%w[--drb --drb-port 8181 --color])
          RSpec::Core::ConfigurationOptions.stub(:new) { @options }

          @drb_proxy = double(RSpec::Core::DRbCommandLine, :run => true)
          RSpec::Core::DRbCommandLine.stub(:new => @drb_proxy)
        end

        it "builds a DRbCommandLine" do
          RSpec::Core::DRbCommandLine.should_receive(:new)
          RSpec::Core::Runner.run(%w[ --drb ], @err, @out)
        end

        it "runs specs over the proxy" do
          @drb_proxy.should_receive(:run).with(@err, @out)
          RSpec::Core::Runner.run(%w[ --drb ], @err, @out)
        end
      end
    end
  end
end
