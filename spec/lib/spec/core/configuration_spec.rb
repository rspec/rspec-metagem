require File.expand_path(File.dirname(__FILE__) + "/../../../spec_helper")

describe Spec::Core::Configuration do

  describe "#mock_with" do

    it "should require and include the mocha adapter when called with :mocha" do
      Spec::Core.configuration.expects(:require).with('spec/core/mocking/with_mocha')
      Spec::Core::Behaviour.expects(:send)
      Spec::Core.configuration.mock_with :mocha
    end

    it "should include the null adapter for nil" do
      Spec::Core::Behaviour.expects(:send).with(:include, Spec::Core::Mocking::WithAbsolutelyNothing)
      Spec::Core.configuration.mock_with nil
    end
    
    # if the below example doesn't pass, @behaviour_instance._setup_mocks and similiar calls fail without a mock library specified
    # this is really a case where cucumber would be a better fit to catch these type of regressions
    it "should include the null adapter by default, if no mocking library is specified" do
      Spec::Core::Behaviour.expects(:send).with(:include, Spec::Core::Mocking::WithAbsolutelyNothing)
      config = Spec::Core::Configuration.new
    end
    
  end  
 
  describe "#include" do

    module InstanceLevelMethods
      def you_call_this_a_blt?
        "egad man, where's the mayo?!?!?"
      end
    end

    it "should include the given module into each matching behaviour" do
      Spec::Core.configuration.include(InstanceLevelMethods, :magic_key => :include)
      group = Spec::Core::Behaviour.describe(Object, 'does like, stuff and junk', :magic_key => :include) { }
      group.should_not respond_to(:you_call_this_a_blt?)
      remove_last_describe_from_world

      group.new.you_call_this_a_blt?.should == "egad man, where's the mayo?!?!?"
    end

  end

  describe "#extend" do

    module ThatThingISentYou

      def that_thing
      end

    end

    it "should extend the given module into each matching behaviour" do
      Spec::Core.configuration.extend(ThatThingISentYou, :magic_key => :extend)      
      group = Spec::Core::Behaviour.describe(ThatThingISentYou, :magic_key => :extend) { }
      
      group.should respond_to(:that_thing)
      remove_last_describe_from_world
    end

  end

  describe "#run_all_when_everything_filtered" do

    it "defaults to true" do
      Spec::Core::Configuration.new.run_all_when_everything_filtered.should == true
    end

    it "can be queried with question method" do
      config = Spec::Core::Configuration.new
      config.run_all_when_everything_filtered = false
      config.run_all_when_everything_filtered?.should == false
    end
  end
  
  describe '#trace?' do
    
    it "is false by default" do
      Spec::Core::Configuration.new.trace?.should == false
    end
    
    it "is true if configuration.trace is true" do
      config = Spec::Core::Configuration.new
      config.trace = true
      config.trace?.should == true
    end
    
  end
  
  describe '#trace' do
    
    it "requires a block" do
      config = Spec::Core::Configuration.new
      config.trace = true
      lambda { config.trace(true) }.should raise_error(ArgumentError)
    end
    
    it "does nothing if trace is false" do
      config = Spec::Core::Configuration.new
      config.trace = false
      config.expects(:puts).with("my trace string is awesome").never
      config.trace { "my trace string is awesome" }
    end
    
    it "allows overriding tracing an optional param" do
      config = Spec::Core::Configuration.new
      config.trace = false
      config.expects(:puts).with(includes("my trace string is awesome"))
      config.trace(true) { "my trace string is awesome" }
    end
       
  end
  
  describe '#formatter' do

    it "sets formatter_to_use based on name" do
      config = Spec::Core::Configuration.new
      config.formatter = :documentation
      config.instance_eval { @formatter_to_use.should == Spec::Core::Formatters::DocumentationFormatter }
      config.formatter = 'documentation'
      config.instance_eval { @formatter_to_use.should == Spec::Core::Formatters::DocumentationFormatter }
    end
    
    it "raises ArgumentError if formatter is unknown" do
      config = Spec::Core::Configuration.new
      lambda { config.formatter = :progresss }.should raise_error(ArgumentError)
    end
    
  end

  describe "filters" do
    
    it "tells you filter is deprecated"
    
    it "responds to exclusion_filter"
    
    it "responds to inclusion_filter"
    
    
  end
end
