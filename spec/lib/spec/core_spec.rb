require File.expand_path(File.dirname(__FILE__) + "/../../spec_helper")

describe Spec::Core do

  describe "#configuration" do
    
    it "should return an instance of Spec::Core::Configuration" do
      Spec::Core.configuration.should be_an_instance_of(Spec::Core::Configuration)
    end
    
  end
  
  describe "#configure" do
    
    it "should yield the current configuration" do
      Spec::Core.configure do |config|
        config.should == Spec::Core.configuration
      end
    end
    
    it "should be callable without a block" do
      Spec::Core.configure
    end
    
  end
  
  describe "#world" do
    
    it "should return the Spec::Core::World instance the current run is using" do
      Spec::Core.world.should be_instance_of(Spec::Core::World)
    end
    
  end
    
end
