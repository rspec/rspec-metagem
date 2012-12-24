require 'spec_helper'

describe "#let" do
  let(:counter) do
    Class.new do
      def initialize
        @count = 0
      end
      def count
        @count += 1
      end
    end.new
  end

  let(:nil_value) do
    @nil_value_count += 1
    nil
  end

  it "generates an instance method" do
    counter.count.should eq(1)
  end

  it "caches the value" do
    counter.count.should eq(1)
    counter.count.should eq(2)
  end

  it "caches a nil value" do
    @nil_value_count = 0
    nil_value
    nil_value

    @nil_value_count.should eq(1)
  end

  let(:a_value) { "a string" }

  context 'when overriding let in a nested context' do
    let(:a_value) { super() + " (modified)" }

    it 'can use `super` to reference the parent context value' do
      expect(a_value).to eq("a string (modified)")
    end
  end

  context 'when the declaration uses `return`' do
    let(:value) do
      return :early_exit if @early_exit
      :late_exit
    end

    it 'can exit the let declaration early' do
      @early_exit = true
      expect(value).to eq(:early_exit)
    end

    it 'can get past a conditional `return` statement' do
      @early_exit = false
      expect(value).to eq(:late_exit)
    end
  end
end

describe "#let!" do
  subject { [1,2,3] }
  let!(:popped) { subject.pop }

  it "evaluates the value non-lazily" do
    subject.should eq([1,2])
  end

  it "returns memoized value from first invocation" do
    popped.should eq(3)
  end
end
