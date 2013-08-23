require 'spec_helper'
require 'rspec/core/formatters/deprecation_formatter'
require 'tempfile'

module RSpec::Core::Formatters
  describe DeprecationFormatter do
    describe "#deprecation" do
      let(:formatter) { DeprecationFormatter.new(deprecation_stream, summary_stream) }
      let(:summary_stream)     { StringIO.new }

      context "with a File deprecation_stream" do
        let(:deprecation_stream) { File.open("#{Dir.tmpdir}/deprecation_summary_example_output", "w+") }

        it "prints a message if provided, ignoring other data" do
          formatter.deprecation(:message => "this message", :deprecated => "x", :replacement => "y", :call_site => "z")
          deprecation_stream.rewind
          expect(deprecation_stream.read).to eq "this message"
        end

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
      end

      context "with an IO deprecation stream" do
        let(:deprecation_stream) { StringIO.new }

        it "prints nothing" do
          5.times { formatter.deprecation(:deprecated => 'i_am_deprecated') }
          expect(deprecation_stream.string).to eq ""
        end
      end
    end

    describe "#deprecation_summary" do
      let(:formatter) { DeprecationFormatter.new(deprecation_stream, summary_stream) }
      let(:summary_stream) { StringIO.new }

      context "with a File deprecation_stream" do
        let(:deprecation_stream) { File.open("#{Dir.tmpdir}/deprecation_summary_example_output", "w") }

        it "prints a count of the deprecations" do
          formatter.deprecation(:deprecated => 'i_am_deprecated')
          formatter.deprecation_summary
          expect(summary_stream.string).to match(/1 deprecation logged to .*deprecation_summary_example_output/)
        end

        it "pluralizes the reported deprecation count for more than one deprecation" do
          formatter.deprecation(:deprecated => 'i_am_deprecated')
          formatter.deprecation(:deprecated => 'i_am_deprecated_also')
          formatter.deprecation_summary
          expect(summary_stream.string).to match(/2 deprecations/)
        end

        it "is not printed when there are no deprecations" do
          formatter.deprecation_summary
          expect(summary_stream.string).to eq ""
        end
      end

      context "with an IO deprecation_stream" do
        let(:deprecation_stream) { StringIO.new }

        it "limits the deprecation warnings after 3 calls" do
          5.times { formatter.deprecation(:deprecated => 'i_am_deprecated') }
          formatter.deprecation_summary
          expected = <<-EOS.gsub(/^ {12}/, '')
            \nDeprecation Warnings:

            i_am_deprecated is deprecated.
            i_am_deprecated is deprecated.
            i_am_deprecated is deprecated.
            Too many uses of deprecated 'i_am_deprecated'. Set config.deprecation_stream to a File for full output.
          EOS
          expect(deprecation_stream.string).to eq expected
        end

        it "prints the true deprecation count to the summary_stream" do
          5.times { formatter.deprecation(:deprecated => 'i_am_deprecated') }
          formatter.deprecation_summary
          expect(summary_stream.string).to match /5 deprecation warnings total/
        end
      end
    end
  end
end
