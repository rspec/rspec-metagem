describe "spec command" do
  it "is deprecated" do
    RSpec.should_receive(:warn_deprecation)
    load File.expand_path('../../../bin/spec', __FILE__)
  end
end
