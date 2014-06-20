require "spec_helper"

module RSpec::Core::Notifications
  describe FailedExampleNotification do
    before do
      allow(RSpec.configuration).to receive(:color_enabled?).and_return(true)
    end

    it "uses the default color for the shared example backtrace line" do
      example = nil
      group = RSpec::Core::ExampleGroup.describe "testing" do
        shared_examples_for "a" do
          example = it "fails" do
            expect(1).to eq(2)
          end
        end
        it_behaves_like "a"
      end
      group.run
      fne = FailedExampleNotification.new(example)
      lines = fne.colorized_message_lines
      expect(lines).to include(match("\\e\\[37mShared Example Group:"))
    end
  end
end
