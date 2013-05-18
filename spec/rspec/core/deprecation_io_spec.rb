require 'spec_helper'
require 'tempfile'

module RSpec::Core
  describe DeprecationIO do
    let(:std_err) { StringIO.new }
    let(:io)      { DeprecationIO.new }

    around do |example|
      @original = $stderr
      $stderr = std_err
      example.run
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

    describe 'setting an io' do
      let(:stream) { double "stream", :puts => nil }

      before do
        io.set_output stream
      end

      it 'starts with 0 deprecations' do
        expect(io.deprecations).to eq 0
      end

      it 'counts deprecations' do
        io.puts 'WARN'
        expect(io.deprecations).to eq 1
      end

      it 'logs to the stream' do
        stream.should_receive(:puts).with('WARN').once
        io.puts 'WARN'
      end

      it 'defaults description to the inspect of stream' do
        expect(io.description).to eq stream.inspect
      end
    end

    describe 'setting an io and description' do
      it 'sets description' do
        io.set_output double, 'filename.txt'
        expect(io.description).to eq 'filename.txt'
      end
    end

  end
end
