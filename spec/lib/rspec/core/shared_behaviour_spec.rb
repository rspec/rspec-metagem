require File.expand_path(File.dirname(__FILE__) + "/../../../spec_helper")

describe Rspec::Core::SharedBehaviour do

  it "should add the 'share_examples_for' method to the global namespace" do
    Kernel.should respond_to(:share_examples_for)
  end

  it "should add the 'shared_examples_for' method to the global namespace" do
    Kernel.should respond_to(:shared_examples_for)
  end

  it "should add the 'share_as' method to the global namespace" do
    Kernel.should respond_to(:share_as)
  end

  it "should complain when adding a second shared behaviour with the same name"

  describe "share_examples_for" do

    it "should capture the given name and block in the Worlds collection of shared behaviours" do
      Rspec::Core.world.shared_behaviours.expects(:[]=).with(:foo, anything)
      share_examples_for(:foo) { }
    end

  end


end
