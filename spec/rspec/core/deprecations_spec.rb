require "spec_helper"

describe "deprecated methods" do
  describe RSpec::Core::SharedExampleGroup do
    describe 'share_as' do
      it 'is deprecated' do
        RSpec.should_receive(:deprecate).at_least(:once)
        RSpec::Core::SharedExampleGroup.share_as(:DeprecatedSharedConst) {}
      end
    end
  end
end

