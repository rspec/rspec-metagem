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

  attr_reader :last_cmd_stdout, :last_cmd_stderr

  def run_command(cmd)
    temp_stdout = StringIO.new
    temp_stderr = StringIO.new
    RSpec::Core::Metadata.instance_variable_set(:@relative_path_regex, nil)

    in_current_dir do
      RSpec::Core::Runner.run(cmd.split, temp_stderr, temp_stdout)
    end
  ensure
    RSpec.reset
    RSpec::Core::Metadata.instance_variable_set(:@relative_path_regex, nil)

    # Ensure it gets cached with a proper value -- if we leave it set to nil,
    # and the next spec operates in a different dir, it could get set to an
    # invalid value.
    RSpec::Core::Metadata.relative_path_regex

    @last_cmd_stdout = temp_stdout.string
    @last_cmd_stderr = temp_stderr.string
    stdout.write(@last_cmd_stdout)
    stderr.write(@last_cmd_stderr)
  end
end

RSpec.configure do |c|
  c.define_derived_metadata(:file_path => %r{spec/integration}) do |meta|
    meta[:slow] = true
  end
end
