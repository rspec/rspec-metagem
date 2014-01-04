require 'spec_helper'

describe "expect(...).to be_between(min, max)" do
  it_behaves_like "an RSpec matcher", :valid_value => (10), :invalid_value => (11) do
    let(:matcher) { be_between(1, 10) }
  end

  it "passes if target is between min and max" do
    expect(10).to be_between(1, 10)
  end

  it "fails if target is not between min and max" do
    expect {
      # It does not go to 11
      expect(11).to be_between(1, 10)
    }.to fail_with("expected 11 to be between 1 and 10 (inclusive)")
  end

  it 'indicates it was not comparable if it does not respond to `between?`' do
    expect {
      expect(nil).to be_between(0, 10)
    }.to fail_with("expected nil to be between 0 and 10 (inclusive), but it does not respond to `between?`")
  end

  it 'works with strings' do
    expect("baz").to be_between("bar", "foo")
    expect {
      expect("foo").to be_between("bar", "baz")
    }.to fail_with("expected \"foo\" to be between \"bar\" and \"baz\" (inclusive)")
  end

  it 'works with other Comparable objects' do
    class SizeMatters
      include Comparable
      attr :str
      def <=>(other)
        str.size <=> other.str.size
      end
      def initialize(str)
        @str = str
      end
      def inspect
        @str
      end
    end
    expect(SizeMatters.new("--")).to be_between(SizeMatters.new("-"), SizeMatters.new("---"))
    expect {
      expect(SizeMatters.new("---")).to be_between(SizeMatters.new("-"), SizeMatters.new("--"))
    }.to fail_with("expected --- to be between - and -- (inclusive)")
  end
end

describe "expect(...).not_to be_between(min, max)" do
  it "passes if target is not between min and max" do
    expect(11).not_to be_between(1, 10)
  end

  it "fails if target is between min and max" do
    expect {
      expect(10).not_to be_between(1, 10)
    }.to fail_with("expected 10 not to be between 1 and 10 (inclusive)")
  end
end

describe "composing with other matchers" do
  it "passes when the matchers both match" do
    expect([nil, 2]).to include(a_value_between(2, 4), a_nil_value)
  end

  it "provides a description" do
    description = include(a_value_between(2, 4), an_instance_of(Float)).description
    expect(description).to eq("include (a value between 2 and 4 (inclusive)) and (an instance of Float)")
  end

  it "fails with a clear error message when the matchers do not match" do
    expect {
      expect([nil, 1]).to include(a_value_between(2, 4), a_nil_value)
    }.to fail_with("expected [nil, 1] to include (a value between 2 and 4 (inclusive)) and (a nil value)")
  end
end
