require 'spec_helper'

module RSpec
  module Matchers
    describe "expect(actual).to be_within(delta).of(expected)" do
      it_behaves_like "an RSpec matcher", :valid_value => 5, :invalid_value => -5 do
        let(:matcher) { be_within(2).of(4.0) }
      end

      it "passes when actual == expected" do
        expect(5.0).to be_within(0.5).of(5.0)
      end

      it "passes when actual < (expected + delta)" do
        expect(5.49).to be_within(0.5).of(5.0)
      end

      it "passes when actual > (expected - delta)" do
        expect(4.51).to be_within(0.5).of(5.0)
      end

      it "passes when actual == (expected - delta)" do
        expect(4.5).to be_within(0.5).of(5.0)
      end

      it "passes when actual == (expected + delta)" do
        expect(5.5).to be_within(0.5).of(5.0)
      end

      it "fails when actual < (expected - delta)" do
        expect {
          expect(4.49).to be_within(0.5).of(5.0)
        }.to fail_with("expected 4.49 to be within 0.5 of 5.0")
      end

      it "fails when actual > (expected + delta)" do
        expect {
          expect(5.51).to be_within(0.5).of(5.0)
        }.to fail_with("expected 5.51 to be within 0.5 of 5.0")
      end

      it "works with Time" do
        expect(Time.now).to be_within(0.1).of(Time.now)
      end

      it "provides a description" do
        matcher = be_within(0.5).of(5.0)
        matcher.matches?(5.1)
        expect(matcher.description).to eq "be within 0.5 of 5.0"
      end

      it "raises an error if no expected value is given" do
        matcher = be_within(0.5)
        expect { matcher.matches?(5.1) }.to raise_error(
          ArgumentError, /must set an expected value using #of/
        )
      end

      it "raises an error if the actual does not respond to :-" do
        expect { be_within(0.1).of(0).matches?(nil) }.to raise_error(
          ArgumentError, /The actual value \(nil\) must respond to `-`/
        )
      end
    end

    describe "expect(actual).not_to be_within(delta).of(expected)" do
      it "passes when actual < (expected - delta)" do
        expect(4.49).not_to be_within(0.5).of(5.0)
      end

      it "passes when actual > (expected + delta)" do
        expect(5.51).not_to be_within(0.5).of(5.0)
      end

      it "fails when actual == expected" do
        expect {
          expect(5.0).not_to be_within(0.5).of(5.0)
        }.to fail_with("expected 5.0 not to be within 0.5 of 5.0")
      end

      it "fails when actual < (expected + delta)" do
        expect {
          expect(5.49).not_to be_within(0.5).of(5.0)
        }.to fail_with("expected 5.49 not to be within 0.5 of 5.0")
      end

      it "fails when actual > (expected - delta)" do
        expect {
          expect(4.51).not_to be_within(0.5).of(5.0)
        }.to fail_with("expected 4.51 not to be within 0.5 of 5.0")
      end

      it "fails when actual == (expected - delta)" do
        expect {
          expect(4.5).not_to be_within(0.5).of(5.0)
        }.to fail_with("expected 4.5 not to be within 0.5 of 5.0")
      end

      it "fails when actual == (expected + delta)" do
        expect {
          expect(5.5).not_to be_within(0.5).of(5.0)
        }.to fail_with("expected 5.5 not to be within 0.5 of 5.0")
      end
    end
  end
end
