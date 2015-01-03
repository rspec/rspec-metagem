module ArubaLoader
  extend RSpec::Support::WithIsolatedStdErr
  with_isolated_stderr do
    require 'aruba/api'
  end
end

RSpec.shared_context "aruba support" do
  include Aruba::Api
  let(:stderr) { StringIO.new }
  let(:stdout) { StringIO.new }

  def run_command(cmd)
    in_current_dir do
      RSpec::Core::Runner.run(cmd.split, stderr, stdout)
    end
  ensure
    RSpec.reset
  end

  def in_current_dir
    RSpec::Core::Metadata.instance_variable_set(:@relative_path_regex, nil)
    super { yield }
  ensure
    RSpec::Core::Metadata.instance_variable_set(:@relative_path_regex, nil)
  end
end

RSpec.configure do |c|
  c.define_derived_metadata(:file_path => %r{spec/integration}) do |meta|
    meta[:slow] = true
  end
end
