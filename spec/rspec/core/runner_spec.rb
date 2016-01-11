require 'rspec/core/drb'
require 'support/runner_support'

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

    describe '.autorun' do
      before do
        @original_ivars = Hash[ Runner.instance_variables.map do |ivar|
          [ivar, Runner.instance_variable_get(ivar)]
        end ]
      end

      after do
        (@original_ivars.keys | Runner.instance_variables).each do |ivar|
          if @original_ivars.key?(ivar)
            Runner.instance_variable_set(ivar, @original_ivars[ivar])
          else
            # send is necessary for 1.8.7
            Runner.send(:remove_instance_variable, ivar)
          end
        end
      end

      it 'sets an at_exit hook if none is already set' do
        Runner.instance_eval do
          @autorun_disabled = false
          @installed_at_exit = false
        end

        allow(RSpec::Core::Runner).to receive(:running_in_drb?).and_return(false)
        allow(RSpec::Core::Runner).to receive(:invoke)
        expect(RSpec::Core::Runner).to receive(:at_exit)
        RSpec::Core::Runner.autorun
      end

      it 'does not set the at_exit hook if it is already set' do
        Runner.instance_eval do
          @autorun_disabled = false
          @installed_at_exit = true
        end

        allow(RSpec::Core::Runner).to receive(:running_in_drb?).and_return(false)
        expect(RSpec::Core::Runner).to receive(:at_exit).never
        RSpec::Core::Runner.autorun
      end
    end

    describe "at_exit hook" do
      before { allow(Runner).to receive(:invoke) }

      it 'normally runs the spec suite' do
        Runner.perform_at_exit
        expect(Runner).to have_received(:invoke)
      end

      it 'does not run the suite if an error triggered the exit' do
        begin
          raise "boom"
        rescue
          Runner.perform_at_exit
        end

        expect(Runner).not_to have_received(:invoke)
      end

      it 'stil runs the suite if a `SystemExit` occurs since that is caused by `Kernel#exit`' do
        begin
          exit
        rescue SystemExit
          Runner.perform_at_exit
        end

        expect(Runner).to have_received(:invoke)
      end
    end

    describe "interrupt handling" do
      before { allow(Runner).to receive(:exit!) }

      it 'prints a message the first time, then exits the second time' do
        expect {
          Runner.handle_interrupt
        }.to output(/shutting down/).to_stderr_from_any_process &
          change { RSpec.world.wants_to_quit }.from(a_falsey_value).to(true)

        expect(Runner).not_to have_received(:exit!)

        expect {
          Runner.handle_interrupt
        }.not_to output.to_stderr_from_any_process

        expect(Runner).to have_received(:exit!)
      end
    end

    describe "interrupt catching" do
      let(:interrupt_handlers) { [] }

      before do
        allow(Object).to receive(:trap).with("INT", any_args) do |&block|
          interrupt_handlers << block
        end
      end

      def interrupt
        interrupt_handlers.each(&:call)
      end

      it "adds a handler for SIGINT" do
        expect(interrupt_handlers).to be_empty
        Runner.send(:trap_interrupt)
        expect(interrupt_handlers.size).to eq(1)
      end

      context "with SIGINT once" do
        it "aborts processing" do
          Runner.send(:trap_interrupt)
          expect(Runner).to receive(:handle_interrupt)
          interrupt
        end

        it "does not exit immediately" do
          Runner.send(:trap_interrupt)
          expect_any_instance_of(Object).not_to receive(:exit)
          expect_any_instance_of(Object).not_to receive(:exit!)
          interrupt
        end
      end

      context "with SIGINT twice" do
        it "exits immediately" do
          Runner.send(:trap_interrupt)
          expect_any_instance_of(Object).to receive(:exit!).with(1)
          interrupt
          interrupt
        end
      end
    end

    # This is intermittently slow because this method calls out to the network
    # interface.
    describe ".running_in_drb?", :slow do
      subject { RSpec::Core::Runner.running_in_drb? }

      before do
        allow(::DRb).to receive(:current_server) { drb_server }
      end

      context "when drb server is started with 127.0.0.1" do
        let(:drb_server) do
          instance_double(::DRb::DRbServer, :uri => "druby://127.0.0.1:0000/", :alive? => true)
        end

        it { should be_truthy }
      end

      context "when drb server is started with localhost" do
        let(:drb_server) do
          instance_double(::DRb::DRbServer, :uri => "druby://localhost:0000/", :alive? => true)
        end

        it { should be_truthy }
      end

      context "when drb server is started with another local ip address" do
        let(:drb_server) do
          instance_double(::DRb::DRbServer, :uri => "druby://192.168.0.1:0000/", :alive? => true)
        end

        before do
          allow(::IPSocket).to receive(:getaddress).and_return("192.168.0.1")
        end

        it { should be_truthy }
      end

      context "when drb server is started with another local ip address" do
        let(:drb_server) do
          instance_double(::DRb::DRbServer, :uri => "druby://192.168.0.1:0000/", :alive? => true)
        end

        before do
          allow(::IPSocket).to receive(:getaddress).and_return("192.168.0.1")
        end

        it { should be_truthy }
      end

      context "when drb server is started with 127.0.0.1 but not alive" do
        let(:drb_server) do
          instance_double(::DRb::DRbServer, :uri => "druby://127.0.0.1:0000/", :alive? => false)
        end

        it { should be_falsey }
      end


      context "when no drb server is running" do
        let(:drb_server) do
          raise ::DRb::DRbServerNotFound
        end

        it { should be_falsey }
      end
    end

    describe ".invoke" do
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

    describe ".run" do
      let(:err) { StringIO.new }
      let(:out) { StringIO.new }

      context "with --drb or -X" do
        before(:each) do
          @options = RSpec::Core::ConfigurationOptions.new(%w[--drb --drb-port 8181 --color])
          allow(RSpec::Core::ConfigurationOptions).to receive(:new) { @options }
        end

        def run_specs
          RSpec::Core::Runner.run(%w[ --drb ], err, out)
        end

        context 'and a DRb server is running' do
          it "builds a DRbRunner and runs the specs" do
            drb_proxy = double(RSpec::Core::DRbRunner, :run => true)
            expect(drb_proxy).to receive(:run).with(err, out)

            expect(RSpec::Core::DRbRunner).to receive(:new).and_return(drb_proxy)

            run_specs
          end
        end

        context 'and a DRb server is not running' do
          before(:each) do
            expect(RSpec::Core::DRbRunner).to receive(:new).and_raise(DRb::DRbConnError)
          end

          it "outputs a message" do
            allow(RSpec.configuration).to receive(:files_to_run) { [] }
            expect(err).to receive(:puts).with(
              "No DRb server is running. Running in local process instead ..."
            )
            run_specs
          end

          it "builds a runner instance and runs the specs" do
            process_proxy = double(RSpec::Core::Runner, :run => 0)
            expect(process_proxy).to receive(:run).with(err, out)

            expect(RSpec::Core::Runner).to receive(:new).and_return(process_proxy)

            run_specs
          end

          if RSpec::Support::RubyFeatures.supports_exception_cause?
            it "prevents the DRb error from being listed as the cause of expectation failures" do
              subclass = Class.new(RSpec::Core::Runner) do
                include RSpec::Matchers

                def run(err, out)
                  expect(1).to eq(2)
                end
              end

              expect {
                subclass.run([], StringIO.new, StringIO.new)
              }.to raise_error(RSpec::Expectations::ExpectationNotMetError) do |e|
                expect(e.cause).to be_nil
              end
            end
          end
        end
      end
    end

    context "when run" do
      include_context "Runner support"

      before do
        allow(config.hooks).to receive(:run)
      end

      it "configures streams before command line options" do
        allow(RSpec).to receive(:deprecate)  # remove this and should_receive when ordered
        stdout = StringIO.new
        allow(config).to receive(:load_spec_files)
        allow(config).to receive(:reporter).and_return(double.as_null_object)
        config.output_stream = $stdout

        # this is necessary to ensure that color works correctly on windows
        expect(config).to receive(:error_stream=).ordered
        expect(config).to receive(:output_stream=).ordered
        expect(config).to receive(:force).at_least(:once).ordered

        runner = build_runner
        runner.setup err, stdout
      end

      it "assigns submitted ConfigurationOptions to @options" do
        config_options = ConfigurationOptions.new(%w[--color])
        runner         = Runner.new(config_options)
        expect(runner.instance_exec { @options }).to be(config_options)
      end

      describe "#run" do
        it 'supports a test-queue like subclass that can perform setup once and run different sets of example groups multiple times' do
          order = []

          RSpec.describe("group 1") do
            before { order << :group_1 }
            example("passing") { expect(1).to eq(1) }
          end

          RSpec.describe("group 2") do
            before { order << :group_2 }
            example("failed") { expect(1).to eq(2) }
          end

          subclass = Class.new(Runner) do
            define_method :run_specs do |example_groups|
              set_1, set_2 = example_groups.partition { |g| g.description.include?('1') }
              order << :start_set_1
              super(set_1)
              order << :start_set_2
              super(set_2)
            end
          end

          expect(config).to receive(:load_spec_files).once
          subclass.new(ConfigurationOptions.new([]), config, world).run(err, out)
          expect(order).to eq([:start_set_1, :group_1, :start_set_2, :group_2])
        end

        it 'reports the expected example count accurately, even when subclasses filter example groups' do
          RSpec.describe("group 1") do
            example("1") { }

            context "nested" do
              4.times { example { } }
            end
          end

          RSpec.describe("group 2") do
            example("2") { }
            example("3") { }

            context "nested" do
              4.times { example { } }
            end
          end

          subclass = Class.new(Runner) do
            define_method :run_specs do |example_groups|
              super(example_groups.select { |g| g.description == 'group 2' })
            end
          end

          my_formatter = instance_double(Formatters::BaseFormatter).as_null_object
          config.output_stream = out
          config.deprecation_stream = err
          config.reporter.register_listener(my_formatter, :start)

          allow(config).to receive(:load_spec_files)
          subclass.new(ConfigurationOptions.new([]), config, world).run(err, out)

          expect(my_formatter).to have_received(:start) do |notification|
            expect(notification.count).to eq(6)
          end
        end

        describe "persistence of example statuses" do
          let(:all_examples) { [double("example")] }

          def run
            allow(world).to receive(:all_examples).and_return(all_examples)
            allow(config).to receive(:load_spec_files)

            class_spy(ExampleStatusPersister, :load_from => []).as_stubbed_const

            runner = build_runner
            runner.run(err, out)
          end

          context "when `example_status_persistence_file_path` is configured" do
            it 'persists the status of all loaded examples' do
              config.example_status_persistence_file_path = "examples.txt"
              run
              expect(ExampleStatusPersister).to have_received(:persist).with(all_examples, "examples.txt")
            end
          end

          context "when `example_status_persistence_file_path` is not configured" do
            it 'persists the status of all loaded examples' do
              config.example_status_persistence_file_path = nil
              run
              expect(ExampleStatusPersister).not_to have_received(:persist)
            end
          end
        end

        context "running files" do
          include_context "spec files"

          it "returns 0 if spec passes" do
            runner = build_runner passing_spec_filename
            expect(runner.run(err, out)).to eq 0
          end

          it "returns 1 if spec fails" do
            runner = build_runner failing_spec_filename
            expect(runner.run(err, out)).to eq 1
          end

          it "returns 2 if spec fails and --failure-exit-code is 2" do
            runner = build_runner failing_spec_filename, "--failure-exit-code", "2"
            expect(runner.run(err, out)).to eq 2
          end
        end
      end

      describe "#run with custom output" do
        before { allow(config).to receive_messages :files_to_run => [] }

        let(:output_file) { File.new("#{Dir.tmpdir}/runner_spec_output.txt", 'w') }

        it "doesn't override output_stream" do
          config.output_stream = output_file
          runner = build_runner
          runner.run err, nil
          expect(runner.instance_exec { @configuration.output_stream }).to eq output_file
        end
      end
    end
  end
end
