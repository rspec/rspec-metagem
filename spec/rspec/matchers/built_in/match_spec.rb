require 'spec_helper'

describe "expect(...).to match(expected)" do
  it_behaves_like "an RSpec matcher", :valid_value => 'ab', :invalid_value => 'bc' do
    let(:matcher) { match(/a/) }
  end

  it "passes when target (String) matches expected (Regexp)" do
    expect("string").to match(/tri/)
  end

  it "passes when target (String) matches expected (String)" do
    expect("string").to match("tri")
  end

  it "fails when target (String) does not match expected (Regexp)" do
    expect {
      expect("string").to match(/rings/)
    }.to fail
  end

  it "fails when target (String) does not match expected (String)" do
    expect {
      expect("string").to match("rings")
    }.to fail
  end

  it "provides message, expected and actual on failure" do
    matcher = match(/rings/)
    matcher.matches?("string")
    expect(matcher.failure_message).to eq "expected \"string\" to match /rings/"
  end

  it "provides a diff on failure" do
    allow(RSpec::Matchers.configuration).to receive(:color?).and_return(false)

    failure_message_that_includes_diff = %r%
\s*Diff:
\s*@@ -1,2 \+1,2 @@
\s*-/bar/
\s*\+"foo"%

    expect { expect("foo").to match(/bar/) }.to fail_with(failure_message_that_includes_diff)
  end

  context "when passed a data structure with matchers" do
    it 'passes when the matchers match' do
      expect(["food", 1.1]).to match([ a_string_matching(/foo/), a_value_within(0.2).of(1) ])
    end

    it 'fails when the matchers do not match' do
      expect {
        expect(["fod", 1.1]).to match([ a_string_matching(/foo/), a_value_within(0.2).of(1) ])
      }.to fail_with('expected ["fod", 1.1] to match [(a string matching /foo/), (a value within 0.2 of 1)]')
    end

    it 'provides a description' do
      description = match([ a_string_matching(/foo/), a_value_within(0.2).of(1) ]).description
      expect(description).to eq("match [(a string matching /foo/), (a value within 0.2 of 1)]")
    end
  end
end

describe "expect(...).not_to match(expected)" do
  it "passes when target (String) matches does not match (Regexp)" do
    expect("string").not_to match(/rings/)
  end

  it "passes when target (String) matches does not match (String)" do
    expect("string").not_to match("rings")
  end

  it "fails when target (String) matches expected (Regexp)" do
    expect {
      expect("string").not_to match(/tri/)
    }.to fail
  end

  it "fails when target (String) matches expected (String)" do
    expect {
      expect("string").not_to match("tri")
    }.to fail
  end

  it "provides message, expected and actual on failure" do
    matcher = match(/tri/)
    matcher.matches?("string")
    expect(matcher.failure_message_when_negated).to eq "expected \"string\" not to match /tri/"
  end

  context "when passed a data structure with matchers" do
    it 'passes when the matchers match' do
      expect(["food", 1.1]).not_to match([ a_string_matching(/fod/), a_value_within(0.2).of(1) ])
    end

    it 'fails when the matchers do not match' do
      expect {
        expect(["fod", 1.1]).not_to match([ a_string_matching(/fod/), a_value_within(0.2).of(1) ])
      }.to fail_with('expected ["fod", 1.1] not to match [(a string matching /fod/), (a value within 0.2 of 1)]')
    end
  end
end
