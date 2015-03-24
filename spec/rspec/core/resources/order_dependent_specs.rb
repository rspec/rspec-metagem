# Deliberately named _specs.rb to avoid being loaded except when specified

$global_state_for_bisect_specs = {}

10.times do |i|
  RSpec.describe "Group 1-#{i}" do
    it "passes" do
    end
  end
end

RSpec.describe "Group 2" do
  it "passes" do
    $global_state_for_bisect_specs[:foo] = 1
  end
end

10.times do |i|
  RSpec.describe "Group 3-#{i}" do
    it "passes" do
    end
  end
end

RSpec.describe "Group 4" do
  it "fails" do
    expect($global_state_for_bisect_specs).to eq({})
  end
end
