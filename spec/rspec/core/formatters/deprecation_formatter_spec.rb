require 'spec_helper'
require 'rspec/core/formatters/deprecation_formatter'
require 'tempfile'

module RSpec::Core::Formatters
  describe DeprecationFormatter do
    describe "#deprecation" do
      let(:deprecation_stream) { StringIO.new }
      let(:summary_stream)     { StringIO.new }
      let(:formatter) { DeprecationFormatter[deprecation_stream, summary_stream] }

      it "includes the method" do
        formatter.deprecation(:deprecated => "i_am_deprecated")
        deprecation_stream.rewind
        expect(deprecation_stream.read).to match(/i_am_deprecated is deprecated/)
      end

      it "includes the replacement" do
        formatter.deprecation(:replacement => "use_me")
        deprecation_stream.rewind
        expect(deprecation_stream.read).to match(/Use use_me instead/)
      end

      it "includes the call site if provided" do
        formatter.deprecation(:call_site => "somewhere")
        deprecation_stream.rewind
        expect(deprecation_stream.read).to match(/Called from somewhere/)
      end

      it "prints a message if provided, ignoring other data" do
        formatter.deprecation(:message => "this message", :deprecated => "x", :replacement => "y", :call_site => "z")
        deprecation_stream.rewind
        expect(deprecation_stream.read).to eq "this message"
      end

      it "limits the deprecation warnings after 3 calls" do
        5.times { formatter.deprecation(:deprecated => 'i_am_deprecated') }
        deprecation_stream.rewind
        expected = <<-EOS.gsub(/^ {10}/, '')
          DEPRECATION: i_am_deprecated is deprecated.
          DEPRECATION: i_am_deprecated is deprecated.
          DEPRECATION: i_am_deprecated is deprecated.
          DEPRECATION: Too many uses of deprecated 'i_am_deprecated'. Set config.deprecation_stream to a File for full output
        EOS
        expect(deprecation_stream.read).to eq expected
      end

      context "with a File deprecation stream" do
        let(:deprecation_stream) { File.open("#{Dir.tmpdir}/deprecation_summary_example_output", "w+") }

        it "continues printing all deprecation warnings after the first 3" do
          5.times { formatter.deprecation(:deprecated => 'i_am_deprecated') }
          deprecation_stream.rewind
          expected = Array.new(5) { "i_am_deprecated is deprecated.\n" }.join
          expect(deprecation_stream.read).to eq expected
        end
      end
    end

    describe "#deprecation_summary" do
      let(:deprecation_stream) { File.open("#{Dir.tmpdir}/deprecation_summary_example_output", "w") }
      let(:summary_stream)     { StringIO.new }
      let(:formatter) { DeprecationFormatter[deprecation_stream, summary_stream] }

      it "is printed when deprecations go to a file" do
        formatter.deprecation(:deprecated => 'i_am_deprecated')
        formatter.deprecation_summary
        summary_stream.rewind
        expect(summary_stream.read).to match(/1 deprecation logged to .*deprecation_summary_example_output/)
      end

      it "pluralizes for more than one deprecation" do
        formatter.deprecation(:deprecated => 'i_am_deprecated')
        formatter.deprecation(:deprecated => 'i_am_deprecated_also')
        formatter.deprecation_summary
        summary_stream.rewind
        expect(summary_stream.read).to match(/2 deprecations/)
      end

      it "is not printed when there are no deprecations" do
        formatter.deprecation_summary
        summary_stream.rewind
        expect(summary_stream.read).to eq ""
      end

      it "is not printed when deprecations go to an IO instance" do
        formatter = DeprecationFormatter[StringIO.new, summary_stream]
        expect(formatter).not_to respond_to :deprecation_summary
      end
    end
  end
end
