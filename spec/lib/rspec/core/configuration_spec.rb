require File.expand_path(File.dirname(__FILE__) + "/../../../spec_helper")

describe Rspec::Core::Configuration do

  describe "setting mock_framework" do

    # TODO: Solution to test rr/rspec/flexmock, possibly cucumber
    it "should require and include the mocha adapter when the mock_framework is :mocha" do
      config = Rspec::Core::Configuration.new
      config.expects(:require).with('rspec/core/mocking/with_mocha')
      Rspec::Core::ExampleGroup.expects(:send)
      config.mock_framework = :mocha
    end

    it "should include the null adapter when the mock_framework is not :rspec, :mocha, or :rr" do
      config = Rspec::Core::Configuration.new
      Rspec::Core::ExampleGroup.expects(:send).with(:include, Rspec::Core::Mocking::WithAbsolutelyNothing)
      config.mock_framework = :crazy_new_mocking_framework_ive_not_yet_heard_of
    end
    
  end  
 
  describe "setting the files to run" do
    
    it "should gracefully handle being called with nil"
    
  end
  
  describe "include" do

    module InstanceLevelMethods
      def you_call_this_a_blt?
        "egad man, where's the mayo?!?!?"
      end
    end

    pending "should include the given module into each matching behaviour" do
      Rspec::Core.configuration.include(InstanceLevelMethods, :magic_key => :include)
      
      isolate_behaviour do
        group = Rspec::Core::ExampleGroup.describe(Object, 'does like, stuff and junk', :magic_key => :include) { }
        group.should_not respond_to(:you_call_this_a_blt?)
        group.new.you_call_this_a_blt?.should == "egad man, where's the mayo?!?!?"
      end
    end

  end

  describe "extend" do

    module ThatThingISentYou

      def that_thing
      end

    end

    pending "should extend the given module into each matching behaviour" do
      Rspec::Core.configuration.extend(ThatThingISentYou, :magic_key => :extend)      
      group = Rspec::Core::ExampleGroup.describe(ThatThingISentYou, :magic_key => :extend) { }
      
      group.should respond_to(:that_thing)
      remove_last_describe_from_world
    end

  end

  describe "run_all_when_everything_filtered" do

    it "defaults to true" do
      Rspec::Core::Configuration.new.run_all_when_everything_filtered.should == true
    end

    it "can be queried with question method" do
      config = Rspec::Core::Configuration.new
      config.run_all_when_everything_filtered = false
      config.run_all_when_everything_filtered?.should == false
    end
  end
  
  describe 'formatter' do

    # TODO: This just needs to be exposed once the refactoring to hash is complete
    pending "sets formatter_to_use based on name" do
      config = Rspec::Core::Configuration.new
      config.formatter = :documentation
      config.instance_eval { @formatter_to_use.should == Rspec::Core::Formatters::DocumentationFormatter }
      config.formatter = 'documentation'
      config.instance_eval { @formatter_to_use.should == Rspec::Core::Formatters::DocumentationFormatter }
    end
    
    pending "raises ArgumentError if formatter is unknown" do
      config = Rspec::Core::Configuration.new
      lambda { config.formatter = :progresss }.should raise_error(ArgumentError)
    end
    
  end

end
