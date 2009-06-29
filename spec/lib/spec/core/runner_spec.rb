require File.expand_path(File.dirname(__FILE__) + "/../../../spec_helper")

describe Spec::Core::Runner do

  before do 
    @runner = Spec::Core::Runner.new
  end

  describe '#configuration' do

    it "should return Spec::Core.configuration" do
      @runner.configuration.should == Spec::Core.configuration
    end

  end

  describe '#formatter' do

    it 'should return the configured formatter' do
      @runner.formatter.should == Spec::Core.configuration.formatter
    end

  end  
  
  describe 'Spec::Core::Runner.at_exit' do
    
    it 'should set an at_exit hook if none is already set' do
      Spec::Core::Runner.stubs(:installed_at_exit?).returns(false)
      Spec::Core::Runner.expects(:at_exit)
      Spec::Core::Runner.autorun
    end
    
    it 'should not set the at_exit hook if it is already set' do
      Spec::Core::Runner.stubs(:installed_at_exit?).returns(true)
      Spec::Core::Runner.expects(:at_exit).never
      Spec::Core::Runner.autorun
    end
    
  end
  
end