require 'fakefs/safe'

module ConfigOptionsHelper
  extend RSpec::SharedContext

  before do
    FakeFS.activate!
    @orig_spec_opts = ENV["SPEC_OPTS"]
    ENV.delete("SPEC_OPTS")
  end

  after do
    FakeFS::FileSystem.clear
    ENV["SPEC_OPTS"] = @orig_spec_opts
    FakeFS.deactivate!
  end

  def config_options_object(*args)
    coo = RSpec::Core::ConfigurationOptions.new(args)
    coo.parse_options
    coo
  end

  def parse_options(*args)
    config_options_object(*args).options
  end
end
