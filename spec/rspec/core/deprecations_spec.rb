require "spec_helper"

describe "deprecations" do
  describe "Spec" do
    RSpec.should_receive(:warn).with /Spec .* RSpec/i
    Spec
  end
end
