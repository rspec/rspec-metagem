require 'spec_helper'

describe Rspec::Core::KernelExtensions do
  
  it "should be included in Object" do
    Kernel.included_modules.should include(Rspec::Core::KernelExtensions)
  end
  
  it "should add a describe method to Object" do
    Object.should respond_to(:describe)
  end

end
