require "spec_helper"

module RSpec::Core
  describe BacktraceCleaner do
    context "with no patterns" do
      it "keeps all lines" do
        lines = ["/tmp/a_file", "some_random_text", "hello\330\271!"]
        cleaner = BacktraceCleaner.new([], [])
        expect(lines.all? {|line| cleaner.include? line}).to be_true
      end
    end

    context "with a discard pattern but no keep patterns" do
      it "discards lines that match the discard pattern" do
        cleaner = BacktraceCleaner.new([], [/remove/])
        expect(cleaner.include? "remove me").to be_false
      end

      it "keeps lines that do not match the discard pattern" do
        cleaner = BacktraceCleaner.new([], [/remove/])
        expect(cleaner.include? "apple").to be_true
      end
    end

    context "with a discard pattern and a keep pattern" do
      it "discards lines that match the discard pattern but not the keep pattern" do
        cleaner = BacktraceCleaner.new([/keep/], [/discard/])
        expect(cleaner.include? "discard").to be_false
      end

      it "keeps lines that match the keep pattern and the discard pattern" do
        cleaner = BacktraceCleaner.new([/hi/], [/.*/])
        expect(cleaner.include? "hi").to be_true
      end

      it "keeps lines that do not match the keep pattern, but do not match a discard pattern" do
        cleaner = BacktraceCleaner.new([/hi/], [/delete/])
        expect(cleaner.include? "fish").to be_true
      end
    end
  end
end
