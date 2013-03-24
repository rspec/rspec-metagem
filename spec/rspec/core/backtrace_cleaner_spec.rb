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

    context "with a discard pattern but no keep patterns" do
      it "discards lines that match the discard pattern" do
        cleaner = BacktraceCleaner.new([], [/remove/])
        expect(cleaner.exclude? "remove me").to be_true
      end

      it "keeps lines that do not match the discard pattern" do
        cleaner = BacktraceCleaner.new([], [/remove/])
        expect(cleaner.exclude? "apple").to be_false
      end
    end

    context "with a discard pattern and a keep pattern" do
      it "discards lines that match the discard pattern but not the keep pattern" do
        cleaner = BacktraceCleaner.new([/keep/], [/discard/])
        expect(cleaner.exclude? "discard").to be_true
      end

      it "keeps lines that match the keep pattern and the discard pattern" do
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
