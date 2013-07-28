require 'spec_helper'
require 'rspec/core/formatters/deprecation_formatter'
require 'tempfile'

module RSpec::Core::Formatters
  RSpec.describe DeprecationFormatter do

    describe '#notifications' do
      it 'returns the notifications the deprecation formatter implements' do
        expect(DeprecationFormatter.new(nil, nil).notifications).to eq [:deprecation, :deprecation_summary]
      end
    end

    describe "#deprecation" do
      let(:formatter) { DeprecationFormatter.new(deprecation_stream, summary_stream) }
      let(:summary_stream)     { StringIO.new }

      context "with a File deprecation_stream" do
        let(:deprecation_stream) { File.open("#{Dir.tmpdir}/deprecation_summary_example_output", "w+") }

        it "prints a message if provided, ignoring other data" do
          formatter.deprecation(:message => "this message", :deprecated => "x", :replacement => "y", :call_site => "z")
          deprecation_stream.rewind
          expect(deprecation_stream.read).to eq "this message\n"
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

        it 'uses synchronized/non-buffered output to work around odd duplicate output behavior we have observed' do
          expect {
            formatter.deprecation(:deprecated => 'foo')
          }.to change { deprecation_stream.sync }.from(false).to(true)
        end

        it 'does not print duplicate messages' do
          3.times { formatter.deprecation(:deprecated => 'foo') }
          formatter.deprecation_summary

          expect(summary_stream.string).to match(/1 deprecation/)
          expect(File.read(deprecation_stream.path)).to eq("foo is deprecated.\n#{DeprecationFormatter::RAISE_ERROR_CONFIG_NOTICE}")
        end
      end

      context "with an Error deprecation_stream" do
        let(:deprecation_stream) { DeprecationFormatter::RaiseErrorStream.new }

        it 'prints a summary of the number of deprecations found' do
          expect { formatter.deprecation(:deprecated => 'foo') }.to raise_error(RSpec::Core::DeprecationError)

          formatter.deprecation_summary

          expect(summary_stream.string).to eq("\n1 deprecation found.\n")
        end

        it 'pluralizes the count when it is greater than 1' do
          expect { formatter.deprecation(:deprecated => 'foo') }.to raise_error(RSpec::Core::DeprecationError)
          expect { formatter.deprecation(:deprecated => 'bar') }.to raise_error(RSpec::Core::DeprecationError)

          formatter.deprecation_summary

          expect(summary_stream.string).to eq("\n2 deprecations found.\n")
        end
      end

      context "with an IO deprecation_stream" do
        let(:deprecation_stream) { StringIO.new }

        it "groups similar deprecations together" do
          formatter.deprecation(:deprecated => 'i_am_deprecated', :call_site => "foo.rb:1")
          formatter.deprecation(:deprecated => 'i_am_a_different_deprecation')
          formatter.deprecation(:deprecated => 'i_am_deprecated', :call_site => "foo.rb:2")
          formatter.deprecation_summary

          expected = <<-EOS.gsub(/^\s+\|/, '')
            |
            |Deprecation Warnings:
            |
            |i_am_a_different_deprecation is deprecated.
            |
            |i_am_deprecated is deprecated. Called from foo.rb:1.
            |i_am_deprecated is deprecated. Called from foo.rb:2.
            |
            |#{DeprecationFormatter::RAISE_ERROR_CONFIG_NOTICE}
          EOS
          expect(deprecation_stream.string).to eq expected.chomp
        end

        it "limits the deprecation warnings after 3 calls" do
          5.times { |i| formatter.deprecation(:deprecated => 'i_am_deprecated', :call_site => "foo.rb:#{i + 1}") }
          formatter.deprecation_summary
          expected = <<-EOS.gsub(/^\s+\|/, '')
            |
            |Deprecation Warnings:
            |
            |i_am_deprecated is deprecated. Called from foo.rb:1.
            |i_am_deprecated is deprecated. Called from foo.rb:2.
            |i_am_deprecated is deprecated. Called from foo.rb:3.
            |Too many uses of deprecated 'i_am_deprecated'. Set config.deprecation_stream to a File for full output.
            |
            |#{DeprecationFormatter::RAISE_ERROR_CONFIG_NOTICE}
          EOS
          expect(deprecation_stream.string).to eq expected.chomp
        end

        it "limits :message deprecation warnings with different callsites after 3 calls" do
          5.times do |n|
            message = "This is a long string with some callsite info: /path/#{n}/to/some/file.rb:2#{n}3.  And some more stuff can come after."
            formatter.deprecation(:message => message)
          end
          formatter.deprecation_summary
          expected = <<-EOS.gsub(/^\s+\|/, '')
            |
            |Deprecation Warnings:
            |
            |This is a long string with some callsite info: /path/0/to/some/file.rb:203.  And some more stuff can come after.
            |This is a long string with some callsite info: /path/1/to/some/file.rb:213.  And some more stuff can come after.
            |This is a long string with some callsite info: /path/2/to/some/file.rb:223.  And some more stuff can come after.
            |Too many similar deprecation messages reported, disregarding further reports. Set config.deprecation_stream to a File for full output.
            |
            |#{DeprecationFormatter::RAISE_ERROR_CONFIG_NOTICE}
          EOS
          expect(deprecation_stream.string).to eq expected.chomp
        end

        it "prints the true deprecation count to the summary_stream" do
          5.times { |i| formatter.deprecation(:deprecated => 'i_am_deprecated', :call_site => "foo.rb:#{i + 1}") }
          5.times do |n|
            formatter.deprecation(:message => "callsite info: /path/#{n}/to/some/file.rb:2#{n}3.  And some more stuff")
          end
          formatter.deprecation_summary
          expect(summary_stream.string).to match(/10 deprecation warnings total/)
        end

        it 'does not print duplicate messages' do
          3.times { formatter.deprecation(:deprecated => 'foo') }
          formatter.deprecation_summary

          expect(summary_stream.string).to match(/1 deprecation/)

          expected = <<-EOS.gsub(/^\s+\|/, '')
            |
            |Deprecation Warnings:
            |
            |foo is deprecated.
            |
            |#{DeprecationFormatter::RAISE_ERROR_CONFIG_NOTICE}
          EOS

          expect(deprecation_stream.string).to eq expected.chomp
        end
      end
    end
  end
end
