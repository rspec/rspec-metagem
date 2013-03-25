require "spec_helper"

module RSpec::Core
  describe BacktraceCleaner do
    context "with no patterns" do
      it "keeps all lines" do
        lines = ["/tmp/a_file", "some_random_text", "hello\330\271!"]
        cleaner = BacktraceCleaner.new([], [])
        expect(lines.all? {|line| cleaner.exclude? line}).to be_false
      end
    end

    context "with an exclusion pattern but no inclusion patterns" do
      it "excludes lines that match the exclusion pattern" do
        cleaner = BacktraceCleaner.new([], [/remove/])
        expect(cleaner.exclude? "remove me").to be_true
      end

      it "keeps lines that do not match the exclusion pattern" do
        cleaner = BacktraceCleaner.new([], [/remove/])
        expect(cleaner.exclude? "apple").to be_false
      end
    end

    context "with an exclusion pattern and an inclusion pattern" do
      it "excludes lines that match the exclusion pattern but not the inclusion pattern" do
        cleaner = BacktraceCleaner.new([/keep/], [/discard/])
        expect(cleaner.exclude? "discard").to be_true
      end

      it "keeps lines that match the inclusion pattern and the exclusion pattern" do
        cleaner = BacktraceCleaner.new([/hi/], [/.*/])
        expect(cleaner.exclude? "hi").to be_false
      end

      it "keeps lines that match neither pattern" do
        cleaner = BacktraceCleaner.new([/hi/], [/delete/])
        expect(cleaner.exclude? "fish").to be_false
      end
    end
  end
end
