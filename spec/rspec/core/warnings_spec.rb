require "spec_helper"

describe "RSpec deprecations and warnings" do
  describe "#deprecate" do
    it "passes the hash to the reporter" do
      expect(RSpec.configuration.reporter).to receive(:deprecation).with(hash_including :deprecated => "deprecated_method", :replacement => "replacement")
      RSpec.deprecate("deprecated_method", :replacement => "replacement")
    end

    it "adds the call site" do
      expect_deprecation_with_call_site(__FILE__, __LINE__ + 1)
      RSpec.deprecate("deprecated_method")
    end

    it "doesn't override a passed call site" do
      expect_deprecation_with_call_site("some_file.rb", 17)
      RSpec.deprecate("deprecated_method", :call_site => "/some_file.rb:17")
    end
  end

  describe "#warn_deprecation" do
    it "puts message in a hash" do
      expect(RSpec.configuration.reporter).to receive(:deprecation).with(hash_including :message => "this is the message")
      RSpec.warn_deprecation("this is the message")
    end
  end

  shared_examples_for "warning helper" do |helper|
    it 'warns with the message text' do
      expect(::Kernel).to receive(:warn).with /Message/
      RSpec.send(helper, 'Message')
    end

    it 'sets the calling line' do
      expect(::Kernel).to receive(:warn).with /#{__FILE__}:#{__LINE__+1}/
      RSpec.send(helper, 'Message')
    end
  end

  describe "#warning" do
    it 'prepends WARNING:' do
      expect(::Kernel).to receive(:warn).with /WARNING: Message\./
      RSpec.warning 'Message'
    end
    it_should_behave_like 'warning helper', :warning
  end

  describe "#warn_with message, options" do
    it_should_behave_like 'warning helper', :warn_with
  end
end
