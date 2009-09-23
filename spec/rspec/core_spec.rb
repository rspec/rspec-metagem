require 'spec_helper'

describe Rspec::Core do

  describe "#configuration" do
    
    it "should return an instance of Rspec::Core::Configuration" do
      Rspec::Core.configuration.should be_an_instance_of(Rspec::Core::Configuration)
    end
    
  end
  
  describe "#configure" do
    
    it "should yield the current configuration" do
      Rspec::Core.configure do |config|
        config.should == Rspec::Core.configuration
      end
    end
    
    it "should be callable without a block" do
      lambda { Rspec::Core.configure }.should_not raise_error
    end
    
  end
  
  describe "#world" do
    
    it "should return the Rspec::Core::World instance the current run is using" do
      Rspec::Core.world.should be_instance_of(Rspec::Core::World)
    end
    
  end
    
end
