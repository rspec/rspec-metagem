require "spec_helper"

describe "deprecations" do
  describe "Spec" do
    it "is deprecated" do
      RSpec.should_receive(:warn_deprecation).with /Spec .* RSpec/i
      Spec
    end
  end

  describe RSpec::Core::ExampleGroup do
    describe 'running_example' do
      it 'is deprecated' do
        RSpec.should_receive(:warn_deprecation).with /running_example.*example/m
        self.running_example
      end
    end
  end
end
