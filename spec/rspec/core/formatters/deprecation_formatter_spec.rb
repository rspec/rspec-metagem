require 'spec_helper'
require 'rspec/core/formatters/deprecation_formatter'
require 'tempfile'

module RSpec::Core::Formatters
  describe DeprecationFormatter do
    describe 'deprecation summary' do
      it "is printed when deprecations go to a file" do
        file = Tempfile.new('foo')
        summary_stream = StringIO.new
        formatter = DeprecationFormatter.new file.path, summary_stream
        formatter.deprecation(:method => 'whatevs')
        formatter.deprecation_summary
        summary_stream.rewind
        expect(summary_stream.read).to match(/1 deprecation logged to .*foo/)
      end

      it "pluralizes for more than one deprecation" do
        file = Tempfile.new('foo')
        summary_stream = StringIO.new
        formatter = DeprecationFormatter.new file.path, summary_stream
        formatter.deprecation(:method => 'whatevs')
        formatter.deprecation(:method => 'whatevs_else')
        formatter.deprecation_summary
        summary_stream.rewind
        expect(summary_stream.read).to match(/2 deprecations/)
      end

      it "is not printed when there are no deprecations" do
        file = Tempfile.new('foo')
        summary_stream = StringIO.new
        formatter = DeprecationFormatter.new file.path, summary_stream
        formatter.deprecation_summary
        summary_stream.rewind
        expect(summary_stream.read).to eq ""
      end

      it "is not printed when deprecations go to an IO instance" do
        summary_stream = StringIO.new
        formatter = DeprecationFormatter.new StringIO.new, summary_stream
        formatter.deprecation(:method => 'whatevs')
        formatter.deprecation_summary
        summary_stream.rewind
        expect(summary_stream.read).to eq ""
      end
    end
  end
end
