require 'spec_helper'

module RSpec::Core
  describe Runner do
    before do
      RSpec.stub(:configuration).and_return(RSpec::Core::Configuration.new)
    end

    describe 'at_exit' do
      
      it 'sets an at_exit hook if none is already set' do
        RSpec::Core::Runner.stub(:installed_at_exit?).and_return(false)
        RSpec::Core::Runner.stub(:running_in_drb?).and_return(false)
        RSpec::Core::Runner.should_receive(:at_exit)
        RSpec::Core::Runner.autorun
      end
      
      it 'does not set the at_exit hook if it is already set' do
        RSpec::Core::Runner.stub(:installed_at_exit?).and_return(true)
        RSpec::Core::Runner.stub(:running_in_drb?).and_return(false)
        RSpec::Core::Runner.should_receive(:at_exit).never
        RSpec::Core::Runner.autorun
      end
      
    end
    
    # TODO move collaboration specs into this and cover the other situations
    describe "#run" do
      context "with --drb or -X" do
        before(:each) do
          @err, @out = StringIO.new, StringIO.new
          @drb_port, @drb_argv = double(Fixnum), double(Array)

          @non_drb_args = %w[--color --drb-port 8181]
          
          @options = RSpec::Core::ConfigurationOptions.new(%w[--drb --drb-port 8181 --color])
          RSpec::Core::ConfigurationOptions.stub(:new) { @options }

          
          @drb_proxy = double(RSpec::Core::DRbCommandLine, :run => true)
          RSpec::Core::DRbCommandLine.stub(:new => @drb_proxy)
        end
        
        it "builds a DRbCommandLine" do
          RSpec::Core::DRbCommandLine.should_receive(:new)
          RSpec::Core::Runner.new.run(%w[ --drb ], @err, @out)
        end

        it "runs specs over the proxy" do
          @drb_proxy.should_receive(:run).with(@err, @out)
          RSpec::Core::Runner.new.run(%w[ --drb ], @err, @out)
        end
      end
    end
  end
end
