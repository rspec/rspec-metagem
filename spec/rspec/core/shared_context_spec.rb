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

    before_all_hook.should be_true
    before_each_hook.should be_true
    after_each_hook.should be_true
    after_all_hook.should be_true
  end

  it "supports let" do
    whatever = nil
    shared = Module.new do
      extend RSpec::SharedContext
      let(:foo) { 'foo' }
    end
    group = RSpec::Core::ExampleGroup.describe do
      include shared
      example { whatever = foo }
    end

    group.run

    whatever.should eq('foo')
  end
end
