require 'spec_helper'

module RSpec::Core
  describe Runner do
    before do
      RSpec.stub(:configuration).and_return(RSpec::Core::Configuration.new)
    end

    describe 'at_exit' do
      
      it 'should set an at_exit hook if none is already set' do
        RSpec::Core::Runner.stub(:installed_at_exit?).and_return(false)
        RSpec::Core::Runner.should_receive(:at_exit)
        RSpec::Core::Runner.autorun
      end
      
      it 'should not set the at_exit hook if it is already set' do
        RSpec::Core::Runner.stub(:installed_at_exit?).and_return(true)
        RSpec::Core::Runner.should_receive(:at_exit).never
        RSpec::Core::Runner.autorun
      end
      
    end
    
    # This is added in because the examples use --version
    describe "running with --version" do
      it "prints the version" do
        err, out = StringIO.new, StringIO.new
        RSpec::Core::Runner.new.run(%w[ --version ], err, out)
        out.rewind
        out.read.should match(/rspec \d+\.\d+\.\d+/n)
      end
    end
    
    # TODO move collaboration specs into this and cover the other situations
    describe "#run" do
      context "options indicate DRb" do
        before(:each) do
          @err, @out = double("error stream"), double("output stream")
          @drb_port, @drb_argv = double(Fixnum), double(Array)

          @non_drb_args = %w[ --colour ]
          
          @options = RSpec::Core::ConfigurationOptions.new(%w[--drb --drb-port 8181] + @non_drb_args)
          RSpec::Core::ConfigurationOptions.stub(:new) { @options }

          
          @drb_proxy = double(RSpec::Core::Runner::DRbProxy, :run => nil)
          RSpec::Core::Runner::DRbProxy.stub(:new => @drb_proxy)
        end
        
        it "builds a DRbProxy" do
          RSpec::Core::Runner::DRbProxy.should_receive(:new).with(:argv => @non_drb_args, :remote_port => 8181)
          RSpec::Core::Runner.new.run(%w[ --format progress ], @err, @out)
        end
        
        context "with RSPEC_DRB environment variable set" do
          def with_RSPEC_DRB_set_to(val)
            original = ENV['RSPEC_DRB']
            ENV['RSPEC_DRB'] = val
            begin
              yield
            ensure
              ENV['RSPEC_DRB'] = original
            end
          end
          
          context "without config variable set" do
            it "uses RSPEC_DRB value" do
              @options.stub(:drb_port => nil)
              with_RSPEC_DRB_set_to('9000') do
                RSpec::Core::Runner::DRbProxy.should_receive(:new).with(:argv => @non_drb_args, :remote_port => 9000)
                RSpec::Core::Runner.new.run(%w[ --format progress ], @err, @out)
              end
            end
          end
            
          context "and config variable set" do
            it "uses configured value" do
              @options.stub(:drb_port => 5678)
              with_RSPEC_DRB_set_to('9000') do
                RSpec::Core::Runner::DRbProxy.should_receive(:new).with(:argv => @non_drb_args, :remote_port => 5678)
                RSpec::Core::Runner.new.run(%w[ --format progress ], @err, @out)
              end
            end
          end
        end

        it "runs specs over the proxy" do
          @drb_proxy.should_receive(:run).with(@err, @out)
          RSpec::Core::Runner.new.run(%w[ --format progress ], @err, @out)
        end
      end
    end
    
    
  end
end
