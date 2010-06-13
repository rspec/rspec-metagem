require "spec_helper"

module RSpec::Core
  describe Hooks do
    describe "#around" do
      it "is deprecated" do
        RSpec.should_receive(:deprecate)
        subject = Object.new.extend(Hooks)
        subject.around(:each) {}
      end
    end
  end
end
