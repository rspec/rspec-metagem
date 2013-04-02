require 'spec_helper'
require 'tempfile'

module RSpec::Core
  describe DeprecationIO do

    describe 'by default' do
      let(:std_err) { Tempfile.new('stderr') }
      let(:io)      { DeprecationIO.new }

      around do
        @original = $stderr
        $stderr = std_err
        $stderr = @original
      end

      it 'starts with 0 deprecations' do
        expect(io.deprecations).to eq 0
      end

      it 'counts deprecations' do
        io.puts 'WARN'
        expect(io.deprecations).to eq 1
      end

      it 'logs to std err by default' do
        std_err.should_receive(:puts).with('WARN').once
        io.puts 'WARN'
      end
    end

    describe 'setting a filename' do
    end

  end
end
