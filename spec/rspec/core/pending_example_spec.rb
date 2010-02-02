require 'spec_helper'

Rspec::Matchers.define :be_pending do
  match do |example|
    example.metadata[:pending]
  end
end

describe "an example" do
  context "with no block" do
    it "is listed as pending" do
      group = isolated_example_group do
        it "has no block" 
      end
      group.run(stub('reporter').as_null_object)
      group.examples.first.should be_pending
    end
  end
end
