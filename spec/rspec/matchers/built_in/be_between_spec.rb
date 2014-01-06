require 'spec_helper'

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

describe "expect(...).to be_between(min, max)" do
  it_behaves_like "an RSpec matcher", :valid_value => (10), :invalid_value => (11) do
    let(:matcher) { be_between(1, 10) }
  end

  it "passes if target is between min and max (inclusive)" do
    expect(10).to be_between(1, 10)
  end

  it "passes if target is between min and max (exclusive)" do
    expect(9).to be_between(1, 10).exclusive
  end

  it "fails if target is not between min and max (inclusive)" do
    expect {
      # It does not go to 11
      expect(11).to be_between(1, 10)
    }.to fail_with("expected 11 to be between 1 and 10 (inclusive)")
  end

  it "fails if target is not between min and max (exclusive)" do
    expect {
      expect(10).to be_between(1, 10).exclusive
    }.to fail_with("expected 10 to be between 1 and 10 (exclusive)")
  end

  it 'indicates it was not comparable if it does not respond to `between?` (inclusive)' do
    expect {
      expect(nil).to be_between(0, 10)
    }.to fail_with("expected nil to be between 0 and 10 (inclusive), but it does not respond to `between?`")
  end

  it 'indicates it was not comparable if it does not respond to `<` and `>` (exclusive)' do
    expect {
      expect(nil).to be_between(0, 10).exclusive
    }.to fail_with("expected nil to be between 0 and 10 (exclusive), but it does not respond to `<` and `>`")
  end

  it 'works with strings (inclusive)' do
    expect("baz").to be_between("bar", "foo")
    expect {
      expect("foo").to be_between("bar", "baz")
    }.to fail_with("expected \"foo\" to be between \"bar\" and \"baz\" (inclusive)")
  end

  it 'works with strings (exclusive)' do
    expect("baz").to be_between("bar", "foo").exclusive
    expect {
      expect("foo").to be_between("bar", "baz").exclusive
    }.to fail_with("expected \"foo\" to be between \"bar\" and \"baz\" (exclusive)")
  end

  it 'works with other Comparable objects (inclusive)' do
   expect(SizeMatters.new("--")).to be_between(SizeMatters.new("-"), SizeMatters.new("---"))
    expect {
      expect(SizeMatters.new("---")).to be_between(SizeMatters.new("-"), SizeMatters.new("--"))
    }.to fail_with("expected --- to be between - and -- (inclusive)")
  end

  it 'works with other Comparable objects (exclusive)' do
    expect(SizeMatters.new("--")).to be_between(SizeMatters.new("-"), SizeMatters.new("---")).exclusive
    expect {
      expect(SizeMatters.new("---")).to be_between(SizeMatters.new("-"), SizeMatters.new("--")).exclusive
    }.to fail_with("expected --- to be between - and -- (exclusive)")
  end
end

describe "expect(...).not_to be_between(min, max)" do
  it "passes if target is not between min and max (inclusive)" do
    expect(11).not_to be_between(1, 10)
  end

  it "passes if target is not between min and max (exclusive)" do
    expect(11).not_to be_between(1, 10).exclusive
  end

  it "fails if target is between min and max (inclusive)" do
    expect {
      expect(10).not_to be_between(1, 10)
    }.to fail_with("expected 10 not to be between 1 and 10 (inclusive)")
  end

  it "fails if target is between min and max (exclusive)" do
    expect {
      expect(9).not_to be_between(1, 10).exclusive
    }.to fail_with("expected 9 not to be between 1 and 10 (exclusive)")
  end
end

describe "composing with other matchers" do
  it "passes when the matchers both match (inclusive)" do
    expect([nil, 2]).to include(a_value_between(2, 4), a_nil_value)
  end

  it "passes when the matchers both match (exclusive)" do
    expect([nil, 3]).to include(a_value_between(2, 4).exclusive, a_nil_value)
  end

  it 'works with mixed types (even though between? can raise ArgumentErrors) (inclusive)' do
    expect(["baz", Math::PI]).to include( a_value_between(3.1, 3.2), a_value_between("bar", "foo") )

    expect {
      expect(["baz", 2.14]).to include( a_value_between(3.1, 3.2), a_value_between("bar", "foo") )
    }.to fail_with('expected ["baz", 2.14] to include (a value between 3.1 and 3.2 (inclusive)) and (a value between "bar" and "foo" (inclusive))')
  end

  it 'works with mixed types (exclusive)' do
    expect(["baz", Math::PI]).to include( a_value_between(3.1, 3.2).exclusive, a_value_between("bar", "foo").exclusive )

    expect {
      expect(["baz", 2.14]).to include( a_value_between(3.1, 3.2).exclusive, a_value_between("bar", "foo").exclusive )
    }.to fail_with('expected ["baz", 2.14] to include (a value between 3.1 and 3.2 (exclusive)) and (a value between "bar" and "foo" (exclusive))')
  end

  it "provides a description (inclusive)" do
    description = include(a_value_between(2, 4), an_instance_of(Float)).description
    expect(description).to eq("include (a value between 2 and 4 (inclusive)) and (an instance of Float)")
  end

  it "provides a description (exclusive)" do
    description = include(a_value_between(2, 4).exclusive, an_instance_of(Float)).description
    expect(description).to eq("include (a value between 2 and 4 (exclusive)) and (an instance of Float)")
  end

  it "fails with a clear error message when the matchers do not match (inclusive)" do
    expect {
      expect([nil, 1]).to include(a_value_between(2, 4), a_nil_value)
    }.to fail_with("expected [nil, 1] to include (a value between 2 and 4 (inclusive)) and (a nil value)")
  end

  it "fails with a clear error message when the matchers do not match (exclusive)" do
    expect {
      expect([nil, 1]).to include(a_value_between(2, 4).exclusive, a_nil_value)
    }.to fail_with("expected [nil, 1] to include (a value between 2 and 4 (exclusive)) and (a nil value)")
  end
end
