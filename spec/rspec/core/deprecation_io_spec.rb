require 'spec_helper'
require 'tempfile'

module RSpec::Core
  describe DeprecationIO do
    let(:std_err) { Tempfile.new('stderr') }
    let(:io)      { DeprecationIO.new }

    around do
      @original = $stderr
      $stderr = std_err
      $stderr = @original
    end

    describe 'by default' do
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

      it 'leaves description as stderr' do
        expect(io.description).to eq 'STD_ERR'
      end
    end

    describe 'setting a filename' do
      let(:file) { double "file", puts: nil }

      before do
        File.stub(:open).and_return(file)
        io.set_output 'filename.txt'
      end

      it 'starts with 0 deprecations' do
        expect(io.deprecations).to eq 0
      end

      it 'counts deprecations' do
        io.puts 'WARN'
        expect(io.deprecations).to eq 1
      end

      it 'configures a file' do
        File.should_receive(:open).with('filename.txt','w')
        io.puts 'WARN'
      end

      it 'sets description' do
        expect(io.description).to eq 'filename.txt'
      end

      it 'logs to file' do
        file.should_receive(:puts).with('WARN').once
        io.puts 'WARN'
      end
    end

  end
end
