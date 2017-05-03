require 'support/aruba_support'

RSpec.describe 'Output stream' do
  include_context 'aruba support'
  before { clean_current_dir }

  context 'when a formatter set in a configure block' do
    it 'writes to the right output stream' do
      write_file_formatted 'spec/example_spec.rb', "
        RSpec.configure do |c|
          c.formatter = :documentation
          c.output_stream = File.open('saved_output', 'w')
        end

        RSpec.describe 'something' do
          it 'succeeds' do
            true
          end
        end
      "

      run_command ''
      expect(last_cmd_stdout).to be_empty
      in_current_dir do
        expect(File.read('saved_output')).to include('1 example, 0 failures')
      end
    end
  end

end
