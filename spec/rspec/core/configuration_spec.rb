require 'spec/spec_helper'

describe Rspec::Core::Configuration do

  describe "setting the mock framework" do

    # TODO: Solution to test rr/rspec/flexmock, possibly cucumber
    it "requires and includes the mocha adapter when the mock_framework is :mocha" do
      config = Rspec::Core::Configuration.new
      config.expects(:require).with('rspec/core/mocking/with_mocha')
      Rspec::Core::ExampleGroup.expects(:send)
      config.mock_framework = :mocha
    end

    it "supports mock_with for backward compatibility with rspec-1.x" do
      config = Rspec::Core::Configuration.new
      config.expects(:require).with('rspec/core/mocking/with_mocha')
      Rspec::Core::ExampleGroup.expects(:send)
      config.mock_with :mocha
    end
    
    it "includes the null adapter when the mock_framework is not :rspec, :mocha, or :rr" do
      config = Rspec::Core::Configuration.new
      Rspec::Core::ExampleGroup.expects(:send).with(:include, Rspec::Core::Mocking::WithAbsolutelyNothing)
      config.mock_framework = :crazy_new_mocking_framework_ive_not_yet_heard_of
    end
    
  end  
 
  describe "setting the files to run" do

    before do
      @config = Rspec::Core::Configuration.new
    end
    
    it "should load files not following pattern if named explicitly" do
      file = File.expand_path(File.dirname(__FILE__) + "/resources/a_bar.rb")
      @config.files_to_run = file
      @config.files_to_run.should include(file)
    end

    describe "with default --pattern" do

      it "should load files named _spec.rb" do
        dir = File.expand_path(File.dirname(__FILE__) + "/resources/")
        @config.files_to_run = dir
        @config.files_to_run.should == ["#{dir}/a_spec.rb"]
      end

    end

    describe "with explicit pattern (single)" do

      before do
        @config.filename_pattern = "**/*_foo.rb"
      end

      it "should load files following pattern" do
        file = File.expand_path(File.dirname(__FILE__) + "/resources/a_foo.rb")
        @config.files_to_run = file
        @config.files_to_run.should include(file)
      end

      it "should load files in directories following pattern" do
        dir = File.expand_path(File.dirname(__FILE__) + "/resources")
        @config.files_to_run = dir
        @config.files_to_run.should include("#{dir}/a_foo.rb")
      end

      it "should not load files in directories not following pattern" do
        dir = File.expand_path(File.dirname(__FILE__) + "/resources")
        @config.files_to_run = dir
        @config.files_to_run.should_not include("#{dir}/a_bar.rb")
      end
      
    end

    describe "with explicit pattern (comma,separated,values)" do

      before do
        @config.filename_pattern = "**/*_foo.rb,**/*_bar.rb"
      end

      it "should support comma separated values" do
        dir = File.expand_path(File.dirname(__FILE__) + "/resources")
        @config.files_to_run = dir
        @config.files_to_run.should include("#{dir}/a_foo.rb")
        @config.files_to_run.should include("#{dir}/a_bar.rb")
      end

      it "should support comma separated values with spaces" do
        dir = File.expand_path(File.dirname(__FILE__) + "/resources")
        @config.files_to_run = dir
        @config.files_to_run.should include("#{dir}/a_foo.rb")
        @config.files_to_run.should include("#{dir}/a_bar.rb")
      end

    end

  end
  
  describe "include" do

    module InstanceLevelMethods
      def you_call_this_a_blt?
        "egad man, where's the mayo?!?!?"
      end
    end

    it "should include the given module into each matching behaviour" do
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

    it "should extend the given module into each matching behaviour" do
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

    it "sets formatter_to_use based on name" do
      config = Rspec::Core::Configuration.new
      config.formatter = :documentation
      config.formatter.should be_an_instance_of(Rspec::Core::Formatters::DocumentationFormatter)
      config.formatter = 'documentation'
      config.formatter.should be_an_instance_of(Rspec::Core::Formatters::DocumentationFormatter)
    end
    
    it "raises ArgumentError if formatter is unknown" do
      config = Rspec::Core::Configuration.new
      lambda { config.formatter = :progresss }.should raise_error(ArgumentError)
    end
    
  end

end
