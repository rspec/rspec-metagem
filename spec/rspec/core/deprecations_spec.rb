require "spec_helper"

describe "deprecations" do
  describe "Spec" do
    it "is deprecated" do
      RSpec.should_receive(:warn).with /Spec .* RSpec/i
      Spec
    end
  end
end
