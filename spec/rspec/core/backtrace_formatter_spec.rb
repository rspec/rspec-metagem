require "spec_helper"

module RSpec::Core
  RSpec.describe BacktraceFormatter do
    def make_backtrace_formatter(exclusion_patterns=nil, inclusion_patterns=nil)
      BacktraceFormatter.new.tap do |bc|
        bc.exclusion_patterns = exclusion_patterns if exclusion_patterns
        bc.inclusion_patterns = inclusion_patterns if inclusion_patterns
      end
    end

    describe "defaults" do
      it "excludes rspec files" do
        expect(make_backtrace_formatter.exclude?("lib/rspec/core.rb")).to be true
        expect(make_backtrace_formatter.exclude?("lib/rspec/core/foo.rb")).to be true
        expect(make_backtrace_formatter.exclude?("lib/rspec/expectations/foo.rb")).to be true
        expect(make_backtrace_formatter.exclude?("lib/rspec/matchers/foo.rb")).to be true
        expect(make_backtrace_formatter.exclude?("lib/rspec/mocks/foo.rb")).to be true
      end

      it "excludes java files (for JRuby)" do
        expect(make_backtrace_formatter.exclude?("org/jruby/RubyArray.java:2336")).to be true
      end

      it "excludes files within installed gems" do
        expect(make_backtrace_formatter.exclude?('ruby-1.8.7-p334/gems/mygem-2.3.0/lib/mygem.rb')).to be true
      end

      it "includes files in projects containing 'gems' in the name" do
        expect(make_backtrace_formatter.exclude?('code/my-gems-plugin/lib/plugin.rb')).to be false
      end

      it "includes something in the current working directory" do
        expect(make_backtrace_formatter.exclude?("#{Dir.getwd}/arbitrary")).to be false
      end

      it "includes something in the current working directory even with a matching exclusion pattern" do
        formatter = make_backtrace_formatter([/foo/])
        expect(formatter.exclude? "#{Dir.getwd}/foo").to be false
      end
    end

    describe "#format_backtrace" do
      it "excludes lines from rspec libs by default", :unless => RSpec.windows_os? do
        backtrace = [
          "/path/to/rspec-expectations/lib/rspec/expectations/foo.rb:37",
          "/path/to/rspec-expectations/lib/rspec/matchers/foo.rb:37",
          "./my_spec.rb:5",
          "/path/to/rspec-mocks/lib/rspec/mocks/foo.rb:37",
          "/path/to/rspec-core/lib/rspec/core/foo.rb:37"
        ]

        expect(BacktraceFormatter.new.format_backtrace(backtrace)).to eq(["./my_spec.rb:5"])
      end

      it "excludes lines from rspec libs by default", :if => RSpec.windows_os? do
        backtrace = [
          "\\path\\to\\rspec-expectations\\lib\\rspec\\expectations\\foo.rb:37",
          "\\path\\to\\rspec-expectations\\lib\\rspec\\matchers\\foo.rb:37",
          ".\\my_spec.rb:5",
          "\\path\\to\\rspec-mocks\\lib\\rspec\\mocks\\foo.rb:37",
          "\\path\\to\\rspec-core\\lib\\rspec\\core\\foo.rb:37"
        ]

        expect(BacktraceFormatter.new.format_backtrace(backtrace)).to eq([".\\my_spec.rb:5"])
      end

      it "excludes lines that come before at_exit autorun hook" do
        backtrace = [
          "./spec/my_spec.rb:7",
          "./spec/my_spec.rb:5",
          RSpec::Core::Runner::AT_EXIT_HOOK_BACKTRACE_LINE,
          "./spec/my_spec.rb:3"
        ]
        expect(BacktraceFormatter.new.format_backtrace(backtrace)).to eq(["./spec/my_spec.rb:7", "./spec/my_spec.rb:5"])
      end

      context "when every line is filtered out" do
        let(:backtrace) do
          [
            "/path/to/rspec-expectations/lib/rspec/expectations/foo.rb:37",
            "/path/to/rspec-expectations/lib/rspec/matchers/foo.rb:37",
            "/path/to/rspec-mocks/lib/rspec/mocks/foo.rb:37",
            "/path/to/rspec-core/lib/rspec/core/foo.rb:37"
          ]
        end

        it "includes full backtrace" do
          expect(BacktraceFormatter.new.format_backtrace(backtrace).take(4)).to eq backtrace
        end

        it "adds a message explaining everything was filtered" do
          expect(BacktraceFormatter.new.format_backtrace(backtrace).drop(4).join).to match(/Showing full backtrace/)
        end
      end

      context "when rspec is installed in the current working directory" do
        it "excludes lines from rspec libs by default", :unless => RSpec.windows_os? do
          backtrace = [
            "#{Dir.getwd}/.bundle/path/to/rspec-expectations/lib/rspec/expectations/foo.rb:37",
            "#{Dir.getwd}/.bundle/path/to/rspec-expectations/lib/rspec/matchers/foo.rb:37",
            "#{Dir.getwd}/my_spec.rb:5",
            "#{Dir.getwd}/.bundle/path/to/rspec-mocks/lib/rspec/mocks/foo.rb:37",
            "#{Dir.getwd}/.bundle/path/to/rspec-core/lib/rspec/core/foo.rb:37"
          ]

          expect(BacktraceFormatter.new.format_backtrace(backtrace)).to eq(["./my_spec.rb:5"])
        end
      end
    end

    describe "#full_backtrace=true" do
      it "sets full_backtrace true" do
        formatter = make_backtrace_formatter([/discard/],[/keep/])
        formatter.full_backtrace = true
        expect(formatter.full_backtrace?).to be true
      end

      it "preserves exclusion and inclusion patterns" do
        formatter = make_backtrace_formatter([/discard/],[/keep/])
        formatter.full_backtrace = true
        expect(formatter.exclusion_patterns).to eq [/discard/]
        expect(formatter.inclusion_patterns).to eq [/keep/]
      end

      it "keeps all lines, even those that match exclusions" do
        formatter = make_backtrace_formatter([/discard/],[/keep/])
        formatter.full_backtrace = true
        expect(formatter.exclude? "discard").to be false
      end
    end

    describe "#full_backtrace=false (after it was true)" do
      it "sets full_backtrace false" do
        formatter = make_backtrace_formatter([/discard/],[/keep/])
        formatter.full_backtrace = true
        formatter.full_backtrace = false
        expect(formatter.full_backtrace?).to be false
      end

      it "preserves exclusion and inclusion patterns" do
        formatter = make_backtrace_formatter([/discard/],[/keep/])
        formatter.full_backtrace = true
        formatter.full_backtrace = false
        expect(formatter.exclusion_patterns).to eq [/discard/]
        expect(formatter.inclusion_patterns).to eq [/keep/]
      end

      it "excludes lines that match exclusions" do
        formatter = make_backtrace_formatter([/discard/],[/keep/])
        formatter.full_backtrace = true
        formatter.full_backtrace = false
        expect(formatter.exclude? "discard").to be true
      end
    end

    describe "#backtrace_line" do
      let(:formatter) { BacktraceFormatter.new }

      it "trims current working directory" do
        expect(formatter.__send__(:backtrace_line, File.expand_path(__FILE__))).to eq("./spec/rspec/core/backtrace_formatter_spec.rb")
      end

      it "preserves the original line" do
        original_line = File.expand_path(__FILE__)
        formatter.__send__(:backtrace_line, original_line)
        expect(original_line).to eq(File.expand_path(__FILE__))
      end

      it "deals gracefully with a security error" do
        safely do
          formatter.__send__(:backtrace_line, __FILE__)
          # on some rubies, this doesn't raise a SecurityError; this test just
          # assures that if it *does* raise an error, the error is caught inside
        end
      end
    end

    context "with no patterns" do
      it "keeps all lines" do
        lines = ["/tmp/a_file", "some_random_text", "hello\330\271!"]
        formatter = make_backtrace_formatter([], [])
        expect(lines.all? {|line| formatter.exclude? line}).to be false
      end

      it "is considered a full backtrace" do
        expect(make_backtrace_formatter([], []).full_backtrace?).to be true
      end
    end

    context "with an exclusion pattern but no inclusion patterns" do
      it "excludes lines that match the exclusion pattern" do
        formatter = make_backtrace_formatter([/discard/],[])
        expect(formatter.exclude? "discard me").to be true
      end

      it "keeps lines that do not match the exclusion pattern" do
        formatter = make_backtrace_formatter([/discard/],[])
        expect(formatter.exclude? "apple").to be false
      end

      it "is considered a partial backtrace" do
        formatter = make_backtrace_formatter([/discard/],[])
        expect(formatter.full_backtrace?).to be false
      end
    end

    context "with an exclusion pattern and an inclusion pattern" do
      it "excludes lines that match the exclusion pattern but not the inclusion pattern" do
        formatter = make_backtrace_formatter([/discard/],[/keep/])
        expect(formatter.exclude? "discard").to be true
      end

      it "keeps lines that match both patterns" do
        formatter = make_backtrace_formatter([/discard/],[/keep/])
        expect(formatter.exclude? "discard/keep").to be false
      end

      it "keeps lines that match neither pattern" do
        formatter = make_backtrace_formatter([/discard/],[/keep/])
        expect(formatter.exclude? "fish").to be false
      end

      it "is considered a partial backtrace" do
        formatter = make_backtrace_formatter([/discard/],[/keep/])
        expect(formatter.full_backtrace?).to be false
      end
    end
  end
end
