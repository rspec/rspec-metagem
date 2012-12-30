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
