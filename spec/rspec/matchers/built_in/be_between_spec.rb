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
