require 'spec_helper'

describe Rspec::Core::Runner do

  describe 'formatter' do

    it 'should return the configured formatter' do
      Rspec::Core::Runner.new.formatter.should == Rspec::Core.configuration.formatter
    end

  end  
  
  describe 'at_exit' do
    
    it 'should set an at_exit hook if none is already set' do
      Rspec::Core::Runner.stub!(:installed_at_exit?).and_return(false)
      Rspec::Core::Runner.should_receive(:at_exit)
      Rspec::Core::Runner.autorun
    end
    
    it 'should not set the at_exit hook if it is already set' do
      Rspec::Core::Runner.stub!(:installed_at_exit?).and_return(true)
      Rspec::Core::Runner.should_receive(:at_exit).never
      Rspec::Core::Runner.autorun
    end
    
  end
  
  describe 'placeholder' do
    
    # it "should "    
    # Rspec::Core::Runner.new
  end
end
