require "spec_helper"

describe RSpec::SharedContext do
  it "is accessible as RSpec::Core::SharedContext" do
    RSpec::Core::SharedContext
  end

  it "is accessible as RSpec::SharedContext" do
    RSpec::SharedContext
  end

  it "supports before and after hooks" do
    before_all_hook = false
    before_each_hook = false
    after_each_hook = false
    after_all_hook = false
    shared = Module.new do
      extend RSpec::SharedContext
      before(:all) { before_all_hook = true }
      before(:each) { before_each_hook = true }
      after(:each)  { after_each_hook = true }
      after(:all)  { after_all_hook = true }
    end
    group = RSpec::Core::ExampleGroup.describe do
      include shared
      example { }
    end

    group.run

    expect(before_all_hook).to be_true
    expect(before_each_hook).to be_true
    expect(after_each_hook).to be_true
    expect(after_all_hook).to be_true
  end

  it "supports let" do
    shared = Module.new do
      extend RSpec::SharedContext
      let(:foo) { 'foo' }
    end
    group = RSpec::Core::ExampleGroup.describe do
      include shared
    end

    expect(group.new.foo).to eq('foo')
  end

  it 'supports explicit subjects' do
    shared = Module.new do
      extend RSpec::SharedContext
      subject { 17 }
    end

    group = RSpec::Core::ExampleGroup.describe do
      include shared
    end

    expect(group.new.subject).to eq(17)
  end

  it 'supports `its` with an implicit subject' do
    shared = Module.new do
      extend RSpec::SharedContext
      its(:size) { should eq 0 }
    end

    group = RSpec::Core::ExampleGroup.describe(Array) do
      include shared
    end

    group.run
    expect(group.children.first.examples.first.execution_result).to include(:status => "passed")
  end

  %w[describe context].each do |method_name|
    it "supports nested example groups using #{method_name}" do
      shared = Module.new do
        extend RSpec::SharedContext
        send(method_name, "nested using describe") do
          example {}
        end
      end
      group = RSpec::Core::ExampleGroup.describe do
        include shared
      end

      group.run

      expect(group.children.length).to eq(1)
      expect(group.children.first.examples.length).to eq(1)
    end
  end
end
