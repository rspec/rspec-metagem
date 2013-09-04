require "spec_helper"

module RSpec::Core
  describe BacktraceCleaner do
    def make_backtrace_cleaner(exclusion_patterns=nil, inclusion_patterns=nil)
      BacktraceCleaner.new.tap do |bc|
        bc.exclusion_patterns = exclusion_patterns if exclusion_patterns
        bc.inclusion_patterns = inclusion_patterns if inclusion_patterns
      end
    end

    describe "defaults" do
      it "excludes rspec files" do
        expect(make_backtrace_cleaner.exclude?("lib/rspec/core.rb")).to be_truthy
      end

      it "excludes java files (for JRuby)" do
        expect(make_backtrace_cleaner.exclude?("org/jruby/RubyArray.java:2336")).to be_truthy
      end

      it "excludes files within installed gems" do
        expect(make_backtrace_cleaner.exclude?('ruby-1.8.7-p334/gems/mygem-2.3.0/lib/mygem.rb')).to be_truthy
      end

      it "includes files in projects containing 'gems' in the name" do
        expect(make_backtrace_cleaner.exclude?('code/my-gems-plugin/lib/plugin.rb')).to be_falsey
      end

      it "includes something in the current working directory" do
        expect(make_backtrace_cleaner.exclude?("#{Dir.getwd}/arbitrary")).to be_falsey
      end

      it "includes something in the current working directory even with a matching exclusion pattern" do
        cleaner = make_backtrace_cleaner([/foo/])
        expect(cleaner.exclude? "#{Dir.getwd}/foo").to be_falsey
      end
    end

    context "with no patterns" do
      it "keeps all lines" do
        lines = ["/tmp/a_file", "some_random_text", "hello\330\271!"]
        cleaner = make_backtrace_cleaner([], [])
        expect(lines.all? {|line| cleaner.exclude? line}).to be_falsey
      end

      it "is considered a full backtrace" do
        expect(make_backtrace_cleaner([], []).full_backtrace?).to be_truthy
      end
    end

    context "with an exclusion pattern but no inclusion patterns" do
      it "excludes lines that match the exclusion pattern" do
        cleaner = make_backtrace_cleaner([/discard/],[])
        expect(cleaner.exclude? "discard me").to be_truthy
      end

      it "keeps lines that do not match the exclusion pattern" do
        cleaner = make_backtrace_cleaner([/discard/],[])
        expect(cleaner.exclude? "apple").to be_falsey
      end

      it "is considered a partial backtrace" do
        cleaner = make_backtrace_cleaner([/discard/],[])
        expect(cleaner.full_backtrace?).to be_falsey
      end
    end

    context "with an exclusion pattern and an inclusion pattern" do
      it "excludes lines that match the exclusion pattern but not the inclusion pattern" do
        cleaner = make_backtrace_cleaner([/discard/],[/keep/])
        expect(cleaner.exclude? "discard").to be_truthy
      end

      it "keeps lines that match both patterns" do
        cleaner = make_backtrace_cleaner([/discard/],[/keep/])
        expect(cleaner.exclude? "discard/keep").to be_falsey
      end

      it "keeps lines that match neither pattern" do
        cleaner = make_backtrace_cleaner([/discard/],[/keep/])
        expect(cleaner.exclude? "fish").to be_falsey
      end

      it "is considered a partial backtrace" do
        cleaner = make_backtrace_cleaner([/discard/],[/keep/])
        expect(cleaner.full_backtrace?).to be_falsey
      end
    end

    describe "#full_backtrace=true" do
      it "sets full_backtrace true" do
        cleaner = make_backtrace_cleaner([/discard/],[/keep/])
        cleaner.full_backtrace = true
        expect(cleaner.full_backtrace?).to be_truthy
      end

      it "preserves exclusion and inclusion patterns" do
        cleaner = make_backtrace_cleaner([/discard/],[/keep/])
        cleaner.full_backtrace = true
        expect(cleaner.exclusion_patterns).to eq [/discard/]
        expect(cleaner.inclusion_patterns).to eq [/keep/]
      end

      it "keeps all lines, even those that match exclusions" do
        cleaner = make_backtrace_cleaner([/discard/],[/keep/])
        cleaner.full_backtrace = true
        expect(cleaner.exclude? "discard").to be_falsey
      end
    end

    describe "#full_backtrace=false (after it was true)" do
      it "sets full_backtrace false" do
        cleaner = make_backtrace_cleaner([/discard/],[/keep/])
        cleaner.full_backtrace = true
        cleaner.full_backtrace = false
        expect(cleaner.full_backtrace?).to be_falsey
      end

      it "preserves exclusion and inclusion patterns" do
        cleaner = make_backtrace_cleaner([/discard/],[/keep/])
        cleaner.full_backtrace = true
        cleaner.full_backtrace = false
        expect(cleaner.exclusion_patterns).to eq [/discard/]
        expect(cleaner.inclusion_patterns).to eq [/keep/]
      end

      it "excludes lines that match exclusions" do
        cleaner = make_backtrace_cleaner([/discard/],[/keep/])
        cleaner.full_backtrace = true
        cleaner.full_backtrace = false
        expect(cleaner.exclude? "discard").to be_truthy
      end
    end
  end
end
