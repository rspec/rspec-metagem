# Deliberately named _specs.rb to avoid being loaded except when specified


describe "pending spec with no implementation" do
  it "is pending"
end

describe "pending command with block format" do
  context "with content that would fail" do
    it "is pending" do
      pending do
        1.should eq(2)
      end
    end
  end

  context "with content that would pass" do
    it "fails" do
      pending do
        1.should eq(1)
      end
    end
  end
end

describe "passing spec" do
  it "passes" do
    1.should eq(1)
  end
end

describe "failing spec" do
  it "fails" do
    1.should eq(2)
  end
end
