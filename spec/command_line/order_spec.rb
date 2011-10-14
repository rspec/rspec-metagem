require 'spec_helper'

describe 'command line' do
  describe '--order' do
    context 'given "random"' do
      before do
        write_file 'spec/sample_spec.rb', %Q|
          describe 'example' do
            specify('one') { fail }
            specify('two') { fail }
          end
        |
      end

      let(:first_failures) do
        5.times.map do
          run_simple 'rspec spec --order random', false
          all_output =~ /1\) example (one|two)/
          $&
        end
      end

      it 'runs the examples in random order' do
        first_failures.uniq.should =~ [
          '1 ) example one', '1 ) example two'
        ]
      end
    end
  end
end
