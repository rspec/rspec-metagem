require "spec_helper"

describe "deprecations" do
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
