module RSpec
  module Matchers
    RSpec.describe ExpectedsForMultipleDiffs do

      before do
        stub_const("::RSpec::Matchers::ExpectedsForMultipleDiffs::DESCRIPTION_MAX_LENGTH", 30)
      end

      class FakeDiffer
        def self.diff(actual, expected)
          [actual, expected].inspect
        end
      end

      let(:differ) { FakeDiffer }

      let(:message) { "a message" }
      let(:actual) { "actual value" }

      let(:wrapped_value) { described_class.from("expected value") }

      let(:matcher_1) { instance_double(BuiltIn::BaseMatcher, :description => "matcher 1 description", :expected => "expected 1") }
      let(:matcher_2) { instance_double(BuiltIn::BaseMatcher, :description => "matcher 2 description", :expected => "expected 2") }
      let(:matcher_3) { instance_double(BuiltIn::BaseMatcher, :description => "matcher 3 description", :expected => "expected 3") }

      let(:long_description) { "a very very long description for my custom smart matcher, which can be used for everything" }
      let(:truncated_description) { "a very very long descriptio..." }
      let(:matcher_with_long_description) { instance_double(BuiltIn::BaseMatcher, :description => long_description, :expected => "expected value") }

      let(:matcher_without_description_defined) { double("custom matcher", :expected => "expected value", :inspect => "#<CustomMatcher:0xf0c8561a55>") }

      before { allow(matcher_without_description_defined).to receive(:description).and_raise(NoMethodError) }

      describe ".from" do
        it "wraps provided value in ExpectedsForMultipleDiffs" do
          expect(wrapped_value).to be_a(described_class)
        end

        it "returns original value if it was already wrapped" do
          expect(described_class.from(wrapped_value)).to be(wrapped_value)
        end
      end

      describe ".for_many_matchers" do
        let(:wrapped_value) { described_class.for_many_matchers([matcher_1, matcher_2, matcher_3]) }

        it "has a diff for all matchers with their description" do
          expect(wrapped_value.message_with_diff(
            message, differ, actual
          )).to eq(dedent <<-EOS)
            |a message
            |Diff for (matcher 1 description):["actual value", "expected 1"]
            |Diff for (matcher 2 description):["actual value", "expected 2"]
            |Diff for (matcher 3 description):["actual value", "expected 3"]
          EOS
        end
      end

      describe "#message_with_diff" do
        it "returns just provided message if diff is empty" do
          allow(FakeDiffer).to receive(:diff) { "" }
          expect(wrapped_value.message_with_diff(
            message, differ, actual
          )).to eq(dedent <<-EOS)
            |a message
          EOS
        end

        it "returns regular message with diff when single expected" do
          expect(wrapped_value.message_with_diff(
            message, differ, actual
          )).to eq(dedent <<-EOS)
            |a message
            |Diff:["actual value", "expected value"]
          EOS
        end

        it "returns message with diff and matcher description when single expected with matcher" do
          wrapped_value = described_class.for_many_matchers([include("expected value")])

          expect(wrapped_value.message_with_diff(
            message, differ, actual
          )).to eq(dedent <<-EOS)
            |a message
            |Diff for (include "expected value"):["actual value", ["expected value"]]
          EOS
        end

        it "returns message with diff and truncated matcher description if it is too long" do
          wrapped_value = described_class.for_many_matchers([matcher_with_long_description])

          expect(wrapped_value.message_with_diff(
            message, differ, actual
          )).to eq(dedent <<-EOS)
            |a message
            |Diff for (#{truncated_description}):["actual value", "expected value"]
          EOS
        end

        it "handles custom matchers without description defined" do
          wrapped_value = described_class.for_many_matchers([matcher_without_description_defined])

          expect(wrapped_value.message_with_diff(
            message, differ, actual
          )).to eq(dedent <<-EOS)
            |a message
            |Diff for (#{matcher_without_description_defined.inspect}):["actual value", "expected value"]
          EOS
        end
      end

    end
  end
end
