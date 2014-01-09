require 'spec_helper'

describe "expect(...).to be_predicate" do
  it "passes when actual returns true for :predicate?" do
    actual = double("actual", :happy? => true)
    expect(actual).to be_happy
  end

  it 'allows composable aliases to be defined' do
    RSpec::Matchers.alias_matcher :a_user_who_is_happy, :be_happy
    actual = double("actual", :happy? => true)
    expect(actual).to a_user_who_is_happy
    expect(a_user_who_is_happy.description).to eq("a user who is happy")

    RSpec::Matchers.alias_matcher :a_user_who_is_an_admin, :be_an_admin
    actual = double("actual", :admin? => true)
    expect(actual).to a_user_who_is_an_admin
    expect(a_user_who_is_an_admin.description).to eq("a user who is an admin")

    RSpec::Matchers.alias_matcher :an_animal_that_is_a_canine, :be_a_canine
    actual = double("actual", :canine? => true)
    expect(actual).to an_animal_that_is_a_canine
    expect(an_animal_that_is_a_canine.description).to eq("an animal that is a canine")
  end

  it "passes when actual returns true for :predicates? (present tense)" do
    actual = double("actual", :exists? => true, :exist? => true)
    expect(actual).to be_exist
  end

  it "fails when actual returns false for :predicate?" do
    actual = double("actual", :happy? => false)
    expect {
      expect(actual).to be_happy
    }.to fail_with("expected happy? to return true, got false")
  end

  it "fails when actual returns false for :predicate?" do
    actual = double("actual", :happy? => nil)
    expect {
      expect(actual).to be_happy
    }.to fail_with("expected happy? to return true, got nil")
  end

  it "fails when actual does not respond to :predicate?" do
    expect {
      expect(Object.new).to be_happy
    }.to raise_error(NameError, /happy\?/)
  end

  it 'fails when :predicate? is private' do
    privately_happy = Class.new do
      private
        def happy?
          true
        end
    end
    expect { expect(privately_happy.new).to be_happy }.to raise_error
  end

  it "fails on error other than NameError" do
    actual = double("actual")
    expect(actual).to receive(:foo?).and_raise("aaaah")
    expect {
      expect(actual).to be_foo
    }.to raise_error(/aaaah/)
  end

  it "fails on error other than NameError (with the present tense predicate)" do
    actual = Object.new
    expect(actual).to receive(:foos?).and_raise("aaaah")
    expect {
      expect(actual).to be_foo
    }.to raise_error(/aaaah/)
  end

  it "does not support operator chaining like a basic `be` matcher does" do
    matcher = be_happy
    value = double(:happy? => false)
    expect(matcher == value).to be false
  end
end

describe "expect(...).not_to be_predicate" do
  it "passes when actual returns false for :sym?" do
    actual = double("actual", :happy? => false)
    expect(actual).not_to be_happy
  end

  it "passes when actual returns nil for :sym?" do
    actual = double("actual", :happy? => nil)
    expect(actual).not_to be_happy
  end

  it "fails when actual returns true for :sym?" do
    actual = double("actual", :happy? => true)
    expect {
      expect(actual).not_to be_happy
    }.to fail_with("expected happy? to return false, got true")
  end

  it "fails when actual does not respond to :sym?" do
    expect {
      expect(Object.new).not_to be_happy
    }.to raise_error(NameError)
  end
end

describe "expect(...).to be_predicate(*args)" do
  it "passes when actual returns true for :predicate?(*args)" do
    actual = double("actual")
    expect(actual).to receive(:older_than?).with(3).and_return(true)
    expect(actual).to be_older_than(3)
  end

  it "fails when actual returns false for :predicate?(*args)" do
    actual = double("actual")
    expect(actual).to receive(:older_than?).with(3).and_return(false)
    expect {
      expect(actual).to be_older_than(3)
    }.to fail_with("expected older_than?(3) to return true, got false")
  end

  it "fails when actual does not respond to :predicate?" do
    expect {
      expect(Object.new).to be_older_than(3)
    }.to raise_error(NameError)
  end
end

describe "expect(...).not_to be_predicate(*args)" do
  it "passes when actual returns false for :predicate?(*args)" do
    actual = double("actual")
    expect(actual).to receive(:older_than?).with(3).and_return(false)
    expect(actual).not_to be_older_than(3)
  end

  it "fails when actual returns true for :predicate?(*args)" do
    actual = double("actual")
    expect(actual).to receive(:older_than?).with(3).and_return(true)
    expect {
      expect(actual).not_to be_older_than(3)
    }.to fail_with("expected older_than?(3) to return false, got true")
  end

  it "fails when actual does not respond to :predicate?" do
    expect {
      expect(Object.new).not_to be_older_than(3)
    }.to raise_error(NameError)
  end
end

describe "expect(...).to be_predicate(&block)" do
  it "passes when actual returns true for :predicate?(&block)" do
    actual = double("actual")
    delegate = double("delegate")
    expect(actual).to receive(:happy?).and_yield
    expect(delegate).to receive(:check_happy).and_return(true)
    expect(actual).to be_happy { delegate.check_happy }
  end

  it "fails when actual returns false for :predicate?(&block)" do
    actual = double("actual")
    delegate = double("delegate")
    expect(actual).to receive(:happy?).and_yield
    expect(delegate).to receive(:check_happy).and_return(false)
    expect {
      expect(actual).to be_happy { delegate.check_happy }
    }.to fail_with("expected happy? to return true, got false")
  end

  it "fails when actual does not respond to :predicate?" do
    delegate = double("delegate", :check_happy => true)
    expect {
      expect(Object.new).to be_happy { delegate.check_happy }
    }.to raise_error(NameError)
  end
end

describe "expect(...).not_to be_predicate(&block)" do
  it "passes when actual returns false for :predicate?(&block)" do
    actual = double("actual")
    delegate = double("delegate")
    expect(actual).to receive(:happy?).and_yield
    expect(delegate).to receive(:check_happy).and_return(false)
    expect(actual).not_to be_happy { delegate.check_happy }
  end

  it "fails when actual returns true for :predicate?(&block)" do
    actual = double("actual")
    delegate = double("delegate")
    expect(actual).to receive(:happy?).and_yield
    expect(delegate).to receive(:check_happy).and_return(true)
    expect {
      expect(actual).not_to be_happy { delegate.check_happy }
    }.to fail_with("expected happy? to return false, got true")
  end

  it "fails when actual does not respond to :predicate?" do
    delegate = double("delegate", :check_happy => true)
    expect {
      expect(Object.new).not_to be_happy { delegate.check_happy }
    }.to raise_error(NameError)
  end
end

describe "expect(...).to be_predicate(*args, &block)" do
  it "passes when actual returns true for :predicate?(*args, &block)" do
    actual = double("actual")
    delegate = double("delegate")
    expect(actual).to receive(:older_than?).with(3).and_yield(3)
    expect(delegate).to receive(:check_older_than).with(3).and_return(true)
    expect(actual).to be_older_than(3) { |age| delegate.check_older_than(age) }
  end

  it "fails when actual returns false for :predicate?(*args, &block)" do
    actual = double("actual")
    delegate = double("delegate")
    expect(actual).to receive(:older_than?).with(3).and_yield(3)
    expect(delegate).to receive(:check_older_than).with(3).and_return(false)
    expect {
      expect(actual).to be_older_than(3) { |age| delegate.check_older_than(age) }
    }.to fail_with("expected older_than?(3) to return true, got false")
  end

  it "fails when actual does not respond to :predicate?" do
    delegate = double("delegate", :check_older_than => true)
    expect {
      expect(Object.new).to be_older_than(3) { |age| delegate.check_older_than(age) }
    }.to raise_error(NameError)
  end
end

describe "expect(...).not_to be_predicate(*args, &block)" do
  it "passes when actual returns false for :predicate?(*args, &block)" do
    actual = double("actual")
    delegate = double("delegate")
    expect(actual).to receive(:older_than?).with(3).and_yield(3)
    expect(delegate).to receive(:check_older_than).with(3).and_return(false)
    expect(actual).not_to be_older_than(3) { |age| delegate.check_older_than(age) }
  end

  it "fails when actual returns true for :predicate?(*args, &block)" do
    actual = double("actual")
    delegate = double("delegate")
    expect(actual).to receive(:older_than?).with(3).and_yield(3)
    expect(delegate).to receive(:check_older_than).with(3).and_return(true)
    expect {
      expect(actual).not_to be_older_than(3) { |age| delegate.check_older_than(age) }
    }.to fail_with("expected older_than?(3) to return false, got true")
  end

  it "fails when actual does not respond to :predicate?" do
    delegate = double("delegate", :check_older_than => true)
    expect {
      expect(Object.new).not_to be_older_than(3) { |age| delegate.check_older_than(age) }
    }.to raise_error(NameError)
  end
end

describe "expect(...).to be_truthy" do
  it "passes when actual equal?(true)" do
    expect(true).to be_truthy
  end

  it "passes when actual is 1" do
    expect(1).to be_truthy
  end

  it "fails when actual equal?(false)" do
    expect {
      expect(false).to be_truthy
    }.to fail_with("expected: truthy value\n     got: false")
  end
end

describe "expect(...).to be_falsey" do
  it "passes when actual equal?(false)" do
    expect(false).to be_falsey
  end

  it "passes when actual equal?(nil)" do
    expect(nil).to be_falsey
  end

  it "fails when actual equal?(true)" do
    expect {
      expect(true).to be_falsey
    }.to fail_with("expected: falsey value\n     got: true")
  end
end

describe "expect(...).to be_falsy" do
  it "passes when actual equal?(false)" do
    expect(false).to be_falsy
  end

  it "passes when actual equal?(nil)" do
    expect(nil).to be_falsy
  end

  it "fails when actual equal?(true)" do
    expect {
      expect(true).to be_falsy
    }.to fail_with("expected: falsey value\n     got: true")
  end
end

describe "expect(...).to be_nil" do
  it "passes when actual is nil" do
    expect(nil).to be_nil
  end

  it "fails when actual is not nil" do
    expect {
      expect(:not_nil).to be_nil
    }.to fail_with(/^expected: nil/)
  end
end

describe "expect(...).not_to be_nil" do
  it "passes when actual is not nil" do
    expect(:not_nil).not_to be_nil
  end

  it "fails when actual is nil" do
    expect {
      expect(nil).not_to be_nil
    }.to fail_with(/^expected: not nil/)
  end
end

describe "expect(...).to be <" do
  it "passes when < operator returns true" do
    expect(3).to be < 4
  end

  it "fails when < operator returns false" do
    expect {
      expect(3).to be < 3
    }.to fail_with("expected: < 3\n     got:   3")
  end

  it "describes itself" do
    expect(be.<(4).description).to eq "be < 4"
  end

  it 'does not lie and say that it is equal to a number' do
    matcher = (be < 3)
    expect(5 == matcher).to be false
  end
end

describe "expect(...).to be <=" do
  it "passes when <= operator returns true" do
    expect(3).to be <= 4
    expect(4).to be <= 4
  end

  it "fails when <= operator returns false" do
    expect {
      expect(3).to be <= 2
    }.to fail_with("expected: <= 2\n     got:    3")
  end
end

describe "expect(...).to be >=" do
  it "passes when >= operator returns true" do
    expect(4).to be >= 4
    expect(5).to be >= 4
  end

  it "fails when >= operator returns false" do
    expect {
      expect(3).to be >= 4
    }.to fail_with("expected: >= 4\n     got:    3")
  end
end

describe "expect(...).to be >" do
  it "passes when > operator returns true" do
    expect(5).to be > 4
  end

  it "fails when > operator returns false" do
    expect {
      expect(3).to be > 4
    }.to fail_with("expected: > 4\n     got:   3")
  end
end

describe "expect(...).to be ==" do
  it "passes when == operator returns true" do
    expect(5).to be == 5
  end

  it "fails when == operator returns false" do
    expect {
      expect(3).to be == 4
    }.to fail_with("expected: == 4\n     got:    3")
  end

  it 'works when the target overrides `#send`' do
    klass = Struct.new(:message) do
      def send
        :message_sent
      end
    end

    msg_1 = klass.new("hello")
    msg_2 = klass.new("hello")
    expect(msg_1).to be == msg_2
  end
end

describe "expect(...).to be =~" do
  it "passes when =~ operator returns true" do
    expect("a string").to be =~ /str/
  end

  it "fails when =~ operator returns false" do
    expect {
      expect("a string").to be =~ /blah/
    }.to fail_with(%Q|expected: =~ /blah/\n     got:    "a string"|)
  end
end

describe "should be =~", :uses_should do
  it "passes when =~ operator returns true" do
    "a string".should be =~ /str/
  end

  it "fails when =~ operator returns false" do
    expect {
      "a string".should be =~ /blah/
    }.to fail_with(%Q|expected: =~ /blah/\n     got:    "a string"|)
  end
end

describe "expect(...).to be ===" do
  it "passes when === operator returns true" do
    expect(Hash).to be === Hash.new
  end

  it "fails when === operator returns false" do
    expect {
      expect(Hash).to be === "not a hash"
    }.to fail_with(%[expected: === "not a hash"\n     got:     Hash])
  end
end

describe "expect(...).not_to with comparison operators" do
  it "coaches user to stop using operators with expect().not_to with numerical comparison operators" do
    expect {
      expect(5).not_to be < 6
    }.to fail_with("`expect(5).not_to be < 6` not only FAILED, it is a bit confusing.")

    expect {
      expect(5).not_to be <= 6
    }.to fail_with("`expect(5).not_to be <= 6` not only FAILED, it is a bit confusing.")

    expect {
      expect(6).not_to be > 5
    }.to fail_with("`expect(6).not_to be > 5` not only FAILED, it is a bit confusing.")

    expect {
      expect(6).not_to be >= 5
    }.to fail_with("`expect(6).not_to be >= 5` not only FAILED, it is a bit confusing.")
  end

  it "coaches users to stop using negation with string comparison operators" do
    expect {
      expect("foo").not_to be > "bar"
    }.to fail_with('`expect("foo").not_to be > "bar"` not only FAILED, it is a bit confusing.')
  end
end

describe "expect(...).not_to with equality operators" do
  it "raises normal error with expect().not_to with equality operators" do
    expect {
      expect(6).not_to be == 6
    }.to fail_with("`expect(6).not_to be == 6`")

    expect {
      expect(String).not_to be === "Hello"
    }.to fail_with('`expect(String).not_to be === "Hello"`')
  end
end

describe "expect(...).to be" do
  it "passes if actual is truthy" do
    expect(true).to be
    expect(1).to be
  end

  it "fails if actual is false" do
    expect {
      expect(false).to be
    }.to fail_with("expected false to evaluate to true")
  end

  it "fails if actual is nil" do
    expect {
      expect(nil).to be
    }.to fail_with("expected nil to evaluate to true")
  end

  it "describes itself" do
    expect(be.description).to eq "be"
  end
end

describe "expect(...).not_to be" do
  it "passes if actual is falsy" do
    expect(false).not_to be
    expect(nil).not_to be
  end

  it "fails on true" do
    expect {
      expect(true).not_to be
    }.to fail_with("expected true to evaluate to false")
  end
end

describe "expect(...).to be(value)" do
  it "delegates to equal" do
    matcher = equal(5)
    expect(self).to receive(:equal).with(5).and_return(matcher)
    expect(5).to be(5)
  end
end

describe "expect(...).not_to be(value)" do
  it "delegates to equal" do
    matcher = equal(4)
    expect(self).to receive(:equal).with(4).and_return(matcher)
    expect(5).not_to be(4)
  end
end

describe "'expect(...).to be' with operator" do
  it "includes 'be' in the description" do
    expect((be > 6).description).to match(/be > 6/)
    expect((be >= 6).description).to match(/be >= 6/)
    expect((be <= 6).description).to match(/be <= 6/)
    expect((be < 6).description).to match(/be < 6/)
  end
end


describe "arbitrary predicate with DelegateClass" do
  it "accesses methods defined in the delegating class (LH[#48])" do
    require 'delegate'
    class ArrayDelegate < DelegateClass(Array)
      def initialize(array)
        @internal_array = array
        super(@internal_array)
      end

      def large?
        @internal_array.size >= 5
      end
    end

    delegate = ArrayDelegate.new([1,2,3,4,5,6])
    expect(delegate).to be_large
  end
end

describe "be_a, be_an" do
  it "passes when class matches" do
    expect("foobar").to be_a(String)
    expect([1,2,3]).to be_an(Array)
  end

  it "fails when class does not match" do
    expect("foobar").not_to be_a(Hash)
    expect([1,2,3]).not_to be_an(Integer)
  end
end

describe "be_an_instance_of" do
  it "passes when direct class matches" do
    expect(5).to be_an_instance_of(Fixnum)
  end

  it "fails when class is higher up hierarchy" do
    expect(5).not_to be_an_instance_of(Numeric)
  end
end

