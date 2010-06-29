require 'spec_helper'

describe RSpec::Core do

  describe "#configuration" do
    
    it "returns an instance of RSpec::Core::Configuration" do
      RSpec.configuration.should be_an_instance_of(RSpec::Core::Configuration)
    end

    it "returns the same object every time" do
      RSpec.configuration.should equal(RSpec.configuration)
    end

  end
  
  describe "#configure" do
    
    it "should yield the current configuration" do
      RSpec.configure do |config|
        config.should == RSpec::configuration
      end
    end
    
    it "should be callable without a block" do
      lambda { RSpec.configure }.should_not raise_error
    end
    
  end
  
  describe "#world" do
    
    it "should return the RSpec::Core::World instance the current run is using" do
      RSpec.world.should be_instance_of(RSpec::Core::World)
    end
    
  end
    
end
