require File.expand_path(File.dirname(__FILE__) + "/../../../spec_helper")

describe Rspec::Core::Runner do

  before do 
    @runner = Rspec::Core::Runner.new
  end

  describe '#configuration' do

    it "should return Rspec::Core.configuration" do
      @runner.configuration.should == Rspec::Core.configuration
    end

  end

  describe '#formatter' do

    it 'should return the configured formatter' do
      @runner.formatter.should == Rspec::Core.configuration.formatter
    end

  end  
  
  describe 'Rspec::Core::Runner.at_exit' do
    
    it 'should set an at_exit hook if none is already set' do
      Rspec::Core::Runner.stubs(:installed_at_exit?).returns(false)
      Rspec::Core::Runner.expects(:at_exit)
      Rspec::Core::Runner.autorun
    end
    
    it 'should not set the at_exit hook if it is already set' do
      Rspec::Core::Runner.stubs(:installed_at_exit?).returns(true)
      Rspec::Core::Runner.expects(:at_exit).never
      Rspec::Core::Runner.autorun
    end
    
  end
  
end