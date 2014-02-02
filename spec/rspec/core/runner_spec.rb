require 'spec_helper'
require 'rspec/core/drb_command_line'

module RSpec::Core
  RSpec.describe Runner do
    describe 'invocation' do
      before do
        # Simulate invoking the suite like exe/rspec does.
        allow(RSpec::Core::Runner).to receive(:run)
        RSpec::Core::Runner.invoke
      end

      it 'does not autorun after having been invoked' do
        expect(RSpec::Core::Runner).not_to receive(:at_exit)
        RSpec::Core::Runner.autorun
      end

      it 'prints a warning when autorun is attempted' do
        expect_deprecation_with_call_site(__FILE__, __LINE__ + 1)
        RSpec::Core::Runner.autorun
      end
    end

    describe 'at_exit' do
      it 'sets an at_exit hook if none is already set' do
        allow(RSpec::Core::Runner).to receive(:autorun_disabled?).and_return(false)
        allow(RSpec::Core::Runner).to receive(:installed_at_exit?).and_return(false)
        allow(RSpec::Core::Runner).to receive(:running_in_drb?).and_return(false)
        allow(RSpec::Core::Runner).to receive(:invoke)
        expect(RSpec::Core::Runner).to receive(:at_exit)
        RSpec::Core::Runner.autorun
      end

      it 'does not set the at_exit hook if it is already set' do
        allow(RSpec::Core::Runner).to receive(:autorun_disabled?).and_return(false)
        allow(RSpec::Core::Runner).to receive(:installed_at_exit?).and_return(true)
        allow(RSpec::Core::Runner).to receive(:running_in_drb?).and_return(false)
        expect(RSpec::Core::Runner).to receive(:at_exit).never
        RSpec::Core::Runner.autorun
      end
    end

    # This is intermittently slow because this method calls out to the network
    # interface.
    describe "#running_in_drb?", :slow do
      it "returns true if drb server is started with 127.0.0.1" do
        allow(::DRb).to receive(:current_server).and_return(double(:uri => "druby://127.0.0.1:0000/"))

        expect(RSpec::Core::Runner.running_in_drb?).to be_truthy
      end

      it "returns true if drb server is started with localhost" do
        allow(::DRb).to receive(:current_server).and_return(double(:uri => "druby://localhost:0000/"))

        expect(RSpec::Core::Runner.running_in_drb?).to be_truthy
      end

      it "returns true if drb server is started with another local ip address" do
        allow(::DRb).to receive(:current_server).and_return(double(:uri => "druby://192.168.0.1:0000/"))
        allow(::IPSocket).to receive(:getaddress).and_return("192.168.0.1")

        expect(RSpec::Core::Runner.running_in_drb?).to be_truthy
      end

      it "returns false if no drb server is running" do
        allow(::DRb).to receive(:current_server).and_raise(::DRb::DRbServerNotFound)

        expect(RSpec::Core::Runner.running_in_drb?).to be_falsey
      end
    end

    describe "#invoke" do
      let(:runner) { RSpec::Core::Runner }

      it "runs the specs via #run" do
        allow(runner).to receive(:exit)
        expect(runner).to receive(:run)
        runner.invoke
      end

      it "doesn't exit on success" do
        allow(runner).to receive(:run) { 0 }
        expect(runner).to_not receive(:exit)
        runner.invoke
      end

      it "exits with #run's status on failure" do
        allow(runner).to receive(:run) { 123 }
        expect(runner).to receive(:exit).with(123)
        runner.invoke
      end
    end

    describe "#run" do
      let(:err) { StringIO.new }
      let(:out) { StringIO.new }

      it "tells RSpec to reset" do
        allow(CommandLine).to receive_messages(:new => double.as_null_object)
        allow(RSpec.configuration).to receive_messages(:files_to_run => [], :warn => nil)
        expect(RSpec).to receive(:reset)
        RSpec::Core::Runner.run([], err, out)
      end

      context "with --drb or -X" do
        before(:each) do
          @options = RSpec::Core::ConfigurationOptions.new(%w[--drb --drb-port 8181 --color])
          allow(RSpec::Core::ConfigurationOptions).to receive(:new) { @options }
        end

        def run_specs
          RSpec::Core::Runner.run(%w[ --drb ], err, out)
        end

        context 'and a DRb server is running' do
          it "builds a DRbCommandLine and runs the specs" do
            drb_proxy = double(RSpec::Core::DRbCommandLine, :run => true)
            expect(drb_proxy).to receive(:run).with(err, out)

            expect(RSpec::Core::DRbCommandLine).to receive(:new).and_return(drb_proxy)

            run_specs
          end
        end

        context 'and a DRb server is not running' do
          before(:each) do
            expect(RSpec::Core::DRbCommandLine).to receive(:new).and_raise(DRb::DRbConnError)
          end

          it "outputs a message" do
            allow(RSpec.configuration).to receive(:files_to_run) { [] }
            expect(err).to receive(:puts).with(
              "No DRb server is running. Running in local process instead ..."
            )
            run_specs
          end

          it "builds a CommandLine and runs the specs" do
            process_proxy = double(RSpec::Core::CommandLine, :run => 0)
            expect(process_proxy).to receive(:run).with(err, out)

            expect(RSpec::Core::CommandLine).to receive(:new).and_return(process_proxy)

            run_specs
          end
        end
      end
    end
  end
end
