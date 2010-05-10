require 'spec_helper'

describe Rspec::Core do

  describe "#configuration" do
    
    it "returns an instance of Rspec::Core::Configuration" do
      Rspec.configuration.should be_an_instance_of(Rspec::Core::Configuration)
    end

    it "returns the same object every time" do
      Rspec.configuration.should equal(Rspec.configuration)
    end

  end
  
  describe "#configure" do
    
    it "should yield the current configuration" do
      Rspec.configure do |config|
        config.should == Rspec::configuration
      end
    end
    
    it "should be callable without a block" do
      lambda { Rspec.configure }.should_not raise_error
    end
    
  end
  
  describe "#world" do
    
    it "should return the Rspec::Core::World instance the current run is using" do
      Rspec.world.should be_instance_of(Rspec::Core::World)
    end
    
  end
    
end
