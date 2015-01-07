require 'support/aruba_support'

RSpec.describe 'Shared Example Rerun Commands' do
  include_context "aruba support"
  before { clean_current_dir }

  it 'prints a rerun command for shared examples in external files that works to rerun' do
    write_file "spec/support/shared_examples.rb", """
      RSpec.shared_examples 'a failing example' do
        example { expect(1).to eq(2) }
      end
    """

    write_file "spec/host_group_spec.rb", """
      load File.expand_path('../support/shared_examples.rb', __FILE__)

      RSpec.describe 'A group with shared examples' do
        include_examples 'a failing example'
      end

      RSpec.describe 'A group with a passing example' do
        example { expect(1).to eq(1) }
      end
    """

    run_command ""
    expect(last_cmd_stdout).to include("2 examples, 1 failure")
    run_rerun_command_for_failing_spec
    expect(last_cmd_stdout).to include("1 example, 1 failure")
    # There was originally a bug when doing it again...
    run_rerun_command_for_failing_spec
    expect(last_cmd_stdout).to include("1 example, 1 failure")
  end

  def run_rerun_command_for_failing_spec
    command = last_cmd_stdout[/Failed examples:\s+rspec (\S+) #/, 1]
    run_command command
  end
end
