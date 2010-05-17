require 'spec_helper'

describe RSpec::Core::Runner do

  describe 'reporter' do

    it 'should return the configured formatter' do
      RSpec::Core::Runner.new.reporter.should == RSpec.configuration.formatter
    end

  end  
  
  describe 'at_exit' do
    
    it 'should set an at_exit hook if none is already set' do
      RSpec::Core::Runner.stub!(:installed_at_exit?).and_return(false)
      RSpec::Core::Runner.should_receive(:at_exit)
      RSpec::Core::Runner.autorun
    end
    
    it 'should not set the at_exit hook if it is already set' do
      RSpec::Core::Runner.stub!(:installed_at_exit?).and_return(true)
      RSpec::Core::Runner.should_receive(:at_exit).never
      RSpec::Core::Runner.autorun
    end
    
  end
  
  describe 'placeholder' do
    
    # it "should "    
    # RSpec::Core::Runner.new
  end
end
