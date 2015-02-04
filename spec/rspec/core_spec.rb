require 'rspec/support/spec/prevent_load_time_warnings'

RSpec.describe RSpec do
  fake_minitest = File.expand_path('../../support/fake_minitest', __FILE__)
  it_behaves_like 'a library that issues no warnings when loaded', 'rspec-core',
    # Loading minitest issues warnings, so we put our fake minitest on the load
    # path to prevent the real minitest from being loaded.
    "$LOAD_PATH.unshift '#{fake_minitest}'", 'require "rspec/core"', 'RSpec::Core::Runner.disable_autorun!' do

    pending_when = {
      '1.9.2' => { :description => "issues no warnings when loaded" },
      '1.8.7' => { :description => "issues no warnings when the spec files are loaded" },
      '2.0.0' => { }
    }

    if RUBY_VERSION == '1.9.2' || RUBY_VERSION == '1.8.7'
      before(:example, pending_when.fetch(RUBY_VERSION)) do
        pending "Not working on #{RUBY_DESCRIPTION}"
      end
    end
    if (RUBY_PLATFORM == 'java' && RUBY_VERSION == '2.0.0')
      before(:example, pending_when.fetch(RUBY_VERSION)) do
        skip "Not reliably working on #{RUBY_DESCRIPTION}"
      end
    end
  end

  describe ".configuration" do
    it "returns the same object every time" do
      expect(RSpec.configuration).to equal(RSpec.configuration)
    end
  end

  describe ".configuration=" do
    it "sets the configuration object" do
      configuration = RSpec::Core::Configuration.new

      RSpec.configuration = configuration

      expect(RSpec.configuration).to equal(configuration)
    end
  end

  describe ".configure" do
    it "yields the current configuration" do
      RSpec.configure do |config|
        expect(config).to equal(RSpec::configuration)
      end
    end
  end

  describe ".world" do
    it "returns the same object every time" do
      expect(RSpec.world).to equal(RSpec.world)
    end
  end

  describe ".world=" do
    it "sets the world object" do
      world = RSpec::Core::World.new

      RSpec.world = world

      expect(RSpec.world).to equal(world)
    end
  end

  describe ".current_example" do
    it "sets the example being executed" do
      group = RSpec.describe("an example group")
      example = group.example("an example")

      RSpec.current_example = example
      expect(RSpec.current_example).to be(example)
    end
  end

  describe ".reset" do
    it "resets the configuration and world objects" do
      config_before_reset = RSpec.configuration
      world_before_reset  = RSpec.world

      RSpec.reset

      expect(RSpec.configuration).not_to equal(config_before_reset)
      expect(RSpec.world).not_to equal(world_before_reset)
    end
  end

  describe ".clear_examples" do
    let(:listener) { double("listener") }
    let(:reporter) { RSpec.configuration.reporter }

    before do
      RSpec.configuration.output_stream = StringIO.new
      RSpec.configuration.error_stream = StringIO.new
    end

    it "clears example groups" do
      RSpec.world.example_groups << :example_group

      RSpec.clear_examples

      expect(RSpec.world.example_groups).to be_empty
    end

    it "resets start_time" do
      start_time_before_clear = RSpec.configuration.start_time

      RSpec.clear_examples

      expect(RSpec.configuration.start_time).not_to eq(start_time_before_clear)
    end

    it "clears examples, failed_examples and pending_examples" do
      reporter.start(3)
      pending_ex = failing_ex = nil

      RSpec.describe do
        pending_ex = pending { fail }
        failing_ex = example { fail }
      end.run

      reporter.example_started(failing_ex)
      reporter.example_failed(failing_ex)

      reporter.example_started(pending_ex)
      reporter.example_pending(pending_ex)
      reporter.finish

      reporter.register_listener(listener, :dump_summary)

      expect(listener).to receive(:dump_summary) do |notification|
        expect(notification.examples).to be_empty
        expect(notification.failed_examples).to be_empty
        expect(notification.pending_examples).to be_empty
      end

      RSpec.clear_examples
      reporter.start(0)
      reporter.finish
    end

    it "restores inclusion rules set by configuration" do
      file_path = File.expand_path("foo_spec.rb")
      RSpec.configure do |config|
        config.filter_run_including(:locations => { file_path => [12] })
      end
      allow(RSpec.configuration).to receive(:load).with(file_path)
      allow(reporter).to receive(:report)
      RSpec::Core::Runner.run(["foo_spec.rb:14"])

      expect(
        RSpec.configuration.filter_manager.inclusions[:locations]
      ).to eq(file_path => [12, 14])

      RSpec.clear_examples

      expect(
        RSpec.configuration.filter_manager.inclusions[:locations]
      ).to eq(file_path => [12])
    end

    it "restores exclusion rules set by configuration" do
      RSpec.configure { |config| config.filter_run_excluding(:slow => true) }
      allow(RSpec.configuration).to receive(:load)
      allow(reporter).to receive(:report)
      RSpec::Core::Runner.run(["--tag", "~fast"])

      expect(
        RSpec.configuration.filter_manager.exclusions.rules
      ).to eq(:slow => true, :fast => true)

      RSpec.clear_examples

      expect(
        RSpec.configuration.filter_manager.exclusions.rules
      ).to eq(:slow => true)
    end
  end

  describe "::Core.path_to_executable" do
    it 'returns the absolute location of the exe/rspec file' do
      expect(File.exist? RSpec::Core.path_to_executable).to be_truthy
      expect(File.read(RSpec::Core.path_to_executable)).to include("RSpec::Core::Runner.invoke")
      expect(File.executable? RSpec::Core.path_to_executable).to be_truthy unless RSpec::Support::OS.windows?
    end
  end

  include RSpec::Support::ShellOut

  # This is hard to test :(. Best way I could come up with was starting
  # fresh ruby process w/o this stuff already loaded.
  it "loads mocks and expectations when the constants are referenced", :slow do
    code = 'require "rspec"; puts RSpec::Mocks.name; puts RSpec::Expectations.name'
    out, err, status = run_ruby_with_current_load_path(code)

    expect(err).to eq("")
    expect(out.split("\n")).to eq(%w[ RSpec::Mocks RSpec::Expectations ])
    expect(status.exitstatus).to eq(0)
  end

  it 'correctly raises an error when an invalid const is referenced' do
    expect {
      RSpec::NotAConst
    }.to raise_error(NameError, /RSpec::NotAConst/)
  end
end

