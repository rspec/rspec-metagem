require 'spec_helper'

module RSpec::Core
  describe CommandLineConfiguration do
    describe '#run' do
      context 'given autotest command' do
        let(:config) { described_class.new('autotest') }

        it 'calls Autotest.generate' do
          described_class::Autotest.should_receive(:generate)
          config.run
        end
      end

      context 'given unsupported command' do
        let(:config) { described_class.new('unsupported') }

        it 'raises ArgumentError' do
          lambda { config.run }.should(
            raise_error(ArgumentError, 'unsupported is not a valid option')
          )
        end
      end
    end
  end
end
