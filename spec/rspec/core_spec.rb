require 'spec_helper'
require 'rspec/support/spec/prevent_load_time_warnings'

RSpec.describe RSpec do
  it_behaves_like 'a library that issues no warnings when loaded',
    'rspec-core', 'require "rspec/core"', 'RSpec::Core::Runner.disable_autorun!'

  describe "::configuration" do
    it "returns the same object every time" do
      expect(RSpec.configuration).to equal(RSpec.configuration)
    end
  end

  describe "::configuration=" do
    it "sets the configuration object" do
      configuration = RSpec::Core::Configuration.new

      RSpec.configuration = configuration

      expect(RSpec.configuration).to equal(configuration)
    end
  end

  describe "::configure" do
    it "yields the current configuration" do
      RSpec.configure do |config|
        expect(config).to equal(RSpec::configuration)
      end
    end
  end

  describe "::world" do
    it "returns the same object every time" do
      expect(RSpec.world).to equal(RSpec.world)
    end
  end

  describe "::world=" do
    it "sets the world object" do
      world = RSpec::Core::World.new

      RSpec.world = world

      expect(RSpec.world).to equal(world)
    end
  end

  describe ".current_example" do
    it "sets the example being executed" do
      group = RSpec::Core::ExampleGroup.describe("an example group")
      example = group.example("an example")

      RSpec.current_example = example
      expect(RSpec.current_example).to be(example)
    end
  end

  describe "::reset" do
    it "resets the configuration and world objects" do
      config_before_reset = RSpec.configuration
      world_before_reset  = RSpec.world

      RSpec.reset

      expect(RSpec.configuration).not_to equal(config_before_reset)
      expect(RSpec.world).not_to equal(world_before_reset)
    end
  end

  describe "::Core.path_to_executable" do
    it 'returns the absolute location of the exe/rspec file' do
      expect(File.exist? RSpec::Core.path_to_executable).to be_truthy
      expect(File.executable? RSpec::Core.path_to_executable).to be_truthy
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

