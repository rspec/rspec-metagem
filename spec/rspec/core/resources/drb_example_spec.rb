p RSpec.configuration.output_stream
p RSpec::Core::Runner.running_in_drb?
describe "DUMMY CONTEXT for 'DrbCommandLine with -c option'" do
  it "should be output with green bar" do
    true.should be_true
  end

  it "should be output with red bar" do
    fail "I want to see a red bar!"
  end
end
