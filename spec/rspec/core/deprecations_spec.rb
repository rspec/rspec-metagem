require "spec_helper"

describe "support for deprecation warnings" do
  it "includes the method to deprecate" do
    expect(RSpec).to receive(:warn_deprecation).with(/^DEPRECATION: deprecated_method/)
    RSpec.deprecate("deprecated_method")
  end

  it "includes the replacement when provided" do
    expect(RSpec).to receive(:warn_deprecation).with(/deprecated_method.*\nDEPRECATION:.*replacement/m)
    RSpec.deprecate("deprecated_method", "replacement")
  end

  it "includes the version number when provided" do
    expect(RSpec).to receive(:warn_deprecation).with(/deprecated_method.*rspec-37\.0\.0\nDEPRECATION:.*replacement/m)
    RSpec.deprecate("deprecated_method", "replacement", "37.0.0")
  end

end

describe "deprecated methods" do
  describe "Spec" do
    it "is deprecated" do
      RSpec.should_receive(:warn_deprecation).with(/Spec .* RSpec/i)
      Spec
    end

    it "returns RSpec" do
      RSpec.stub(:warn_deprecation)
      expect(Spec).to eq(RSpec)
    end

    it "doesn't include backward compatibility in const_missing backtrace" do
      RSpec.stub(:warn_deprecation)
      exception = nil
      begin
        ConstantThatDoesNotExist
      rescue Exception => exception
      end
      expect(exception.backtrace.find { |l| l =~ /lib\/rspec\/core\/backward_compatibility/ }).to be_nil
    end
  end

  describe RSpec::Core::ExampleGroup do
    describe 'running_example' do
      it 'is deprecated' do
        RSpec.should_receive(:warn_deprecation)
        self.running_example
      end

      it "delegates to example" do
        RSpec.stub(:warn_deprecation)
        expect(running_example).to eq(example)
      end
    end
  end

  describe RSpec::Core::SharedExampleGroup do
    describe 'share_as' do
      it 'is deprecated' do
        RSpec.should_receive(:warn_deprecation)
        RSpec::Core::SharedExampleGroup.share_as(:DeprecatedSharedConst) {}
      end
    end
  end

  describe "Spec::Runner.configure" do
    it "is deprecated" do
      RSpec.stub(:warn_deprecation)
      RSpec.should_receive(:deprecate)
      Spec::Runner.configure
    end
  end

  describe "Spec::Rake::SpecTask" do
    it "is deprecated" do
      RSpec.stub(:warn_deprecation)
      RSpec.should_receive(:deprecate)
      Spec::Rake::SpecTask
    end

    it "doesn't include backward compatibility in const_missing backtrace" do
      RSpec.stub(:warn_deprecation)
      exception = nil
      begin
        Spec::Rake::ConstantThatDoesNotExist
      rescue Exception => exception
      end
      expect(exception.backtrace.find { |l| l =~ /lib\/rspec\/core\/backward_compatibility/ }).to be_nil
    end
  end

end
