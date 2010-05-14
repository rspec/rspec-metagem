require "spec_helper"

describe "deprecations" do
  describe "Spec" do
    Rspec.should_receive(:warn).with /Spec .* Rspec/i
    Spec
  end
end
