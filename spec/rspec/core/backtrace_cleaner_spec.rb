require "spec_helper"

module RSpec::Core
  describe BacktraceCleaner do
    def make_backtrace_cleaner(exclusion_patterns=nil, inclusion_patterns=nil)
      BacktraceCleaner.new.tap do |bc|
        bc.exclusion_patterns = exclusion_patterns if exclusion_patterns
        bc.inclusion_patterns = inclusion_patterns if inclusion_patterns
      end
    end

    it "keeps anything in the current working directory by default" do
      cleaner = make_backtrace_cleaner
      expect(cleaner.exclude? "#{Dir.getwd}/foo").to be_falsey
    end

    it "keeps anything in the current working directory even with a matching exclusion pattern" do
      cleaner = make_backtrace_cleaner([/foo/])
      expect(cleaner.exclude? "#{Dir.getwd}/foo").to be_falsey
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

      it "keeps all lines, even those that match exclusions" do
        cleaner = make_backtrace_cleaner([/discard/],[/keep/])
        cleaner.full_backtrace = true
        expect(cleaner.exclude? "discard").to be_falsey
      end

      it "preserves exclusion and inclusion patterns" do
        cleaner = make_backtrace_cleaner([/discard/],[/keep/])
        cleaner.full_backtrace = true
        expect(cleaner.exclusion_patterns).to eq [/discard/]
        expect(cleaner.inclusion_patterns).to eq [/keep/]
      end
    end

    describe "#full_backtrace=true (after it was false)" do
      it "sets full_backtrace false" do
        cleaner = make_backtrace_cleaner([/discard/],[/keep/])
        cleaner.full_backtrace = true
        cleaner.full_backtrace = false
        expect(cleaner.full_backtrace?).to be_falsey
      end

      it "excludes lines that match exclusions even those that match exclusions" do
        cleaner = make_backtrace_cleaner([/discard/],[/keep/])
        cleaner.full_backtrace = true
        cleaner.full_backtrace = false
        expect(cleaner.exclude? "discard").to be_truthy
      end

      it "preserves exclusion and inclusion patterns" do
        cleaner = make_backtrace_cleaner([/discard/],[/keep/])
        cleaner.full_backtrace = true
        cleaner.full_backtrace = false
        expect(cleaner.exclusion_patterns).to eq [/discard/]
        expect(cleaner.inclusion_patterns).to eq [/keep/]
      end
    end
  end
end
