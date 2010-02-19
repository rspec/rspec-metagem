require 'spec_helper'

module Rspec::Core

  describe Configuration do

    let(:config) { Configuration.new }

    context "setting the mock framework" do

      it "requires and includes the rspec adapter when the mock_framework is :rspec" do
        config.should_receive(:require).with('rspec/core/mocking/with_rspec')
        ExampleGroup.should_receive(:send)
        config.mock_framework = :rspec
      end

      it "supports mock_with for backward compatibility with rspec-1.x" do
        config.stub!(:require)
        ExampleGroup.stub!(:send)
        config.mock_with :rspec
      end
      
      it "includes the null adapter when the mock_framework is not :rspec, :mocha, or :rr" do
        ExampleGroup.should_receive(:send).with(:include, Mocking::WithAbsolutelyNothing)
        config.mock_framework = :crazy_new_mocking_framework_ive_not_yet_heard_of
      end

      pending "includes the rspec adapter when the mock_framework is not set" do
        ExampleGroup.stub!(:send)
        config.mock_framework.should == :rspec
      end
      
    end  
   
    context "setting the files to run" do

      it "should load files not following pattern if named explicitly" do
        file = "./spec/rspec/core/resources/a_bar.rb"
        config.files_or_directories_to_run = file
        config.files_to_run.should == [file]
      end

      describe "with default --pattern" do

        it "should load files named _spec.rb" do
          dir = "./spec/rspec/core/resources"
          config.files_or_directories_to_run = dir
          config.files_to_run.should == ["#{dir}/a_spec.rb"]
        end

      end

      describe "with explicit pattern (single)" do

        before do
          config.filename_pattern = "**/*_foo.rb"
        end

        it "should load files following pattern" do
          file = File.expand_path(File.dirname(__FILE__) + "/resources/a_foo.rb")
          config.files_or_directories_to_run = file
          config.files_to_run.should include(file)
        end

        it "should load files in directories following pattern" do
          dir = File.expand_path(File.dirname(__FILE__) + "/resources")
          config.files_or_directories_to_run = dir
          config.files_to_run.should include("#{dir}/a_foo.rb")
        end

        it "should not load files in directories not following pattern" do
          dir = File.expand_path(File.dirname(__FILE__) + "/resources")
          config.files_or_directories_to_run = dir
          config.files_to_run.should_not include("#{dir}/a_bar.rb")
        end
        
      end

      context "with explicit pattern (comma,separated,values)" do

        before do
          config.filename_pattern = "**/*_foo.rb,**/*_bar.rb"
        end

        it "should support comma separated values" do
          dir = File.expand_path(File.dirname(__FILE__) + "/resources")
          config.files_or_directories_to_run = dir
          config.files_to_run.should include("#{dir}/a_foo.rb")
          config.files_to_run.should include("#{dir}/a_bar.rb")
        end

        it "should support comma separated values with spaces" do
          dir = File.expand_path(File.dirname(__FILE__) + "/resources")
          config.files_or_directories_to_run = dir
          config.files_to_run.should include("#{dir}/a_foo.rb")
          config.files_to_run.should include("#{dir}/a_bar.rb")
        end

      end

      context "with line number" do

        it "assigns the line number as the filter" do
          config.files_or_directories_to_run = "path/to/a_spec.rb:37"
          config.filter.should == {:line_number => 37}
        end

      end

      context "with full_description" do

        it "assigns the example name as the filter on description" do
          config.full_description = "foo"
          config.filter.should == {:full_description => /foo/}
        end

      end

    end
    
    describe "include" do

      module InstanceLevelMethods
        def you_call_this_a_blt?
          "egad man, where's the mayo?!?!?"
        end
      end

      context "with no filter" do
        it "includes the given module into each example group" do
          config.include(InstanceLevelMethods)
          
          group = ExampleGroup.create(config, 'does like, stuff and junk', :magic_key => :include) { }
          group.should_not respond_to(:you_call_this_a_blt?)
          group.new.you_call_this_a_blt?.should == "egad man, where's the mayo?!?!?"
        end
        
      end

      context "with a filter" do
        it "includes the given module into each matching example group" do
          config.include(InstanceLevelMethods, :magic_key => :include)
          
          group = ExampleGroup.create(config, 'does like, stuff and junk', :magic_key => :include) { }
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

      it "should extend the given module into each matching example group" do
        config.extend(ThatThingISentYou, :magic_key => :extend)      
        group = ExampleGroup.create(config, ThatThingISentYou, :magic_key => :extend) { }
        group.should respond_to(:that_thing)
      end

    end

    describe "run_all_when_everything_filtered" do

      it "defaults to false" do
        config.run_all_when_everything_filtered.should == false
      end

      it "can be queried with question method" do
        config.run_all_when_everything_filtered = true
        config.run_all_when_everything_filtered?.should == true
      end
    end
    
    describe 'formatter=' do

      it "sets formatter_to_use based on name" do
        config.formatter = :documentation
        config.formatter.should be_an_instance_of(Formatters::DocumentationFormatter)
        config.formatter = 'documentation'
        config.formatter.should be_an_instance_of(Formatters::DocumentationFormatter)
      end
      
      it "raises ArgumentError if formatter is unknown" do
        lambda { config.formatter = :progresss }.should raise_error(ArgumentError)
      end
      
    end

    describe "line_number=" do
      it "sets the line number" do
        config.line_number = '37'
        config.filter.should == {:line_number => 37}
      end
      
      it "overrides :focused" do
        config.filter_run :focused => true
        config.line_number = '37'
        config.filter.should == {:line_number => 37}
      end
      
      it "prevents :focused" do
        config.line_number = '37'
        config.filter_run :focused => true
        config.filter.should == {:line_number => 37}
      end
    end

    describe "full_backtrace=" do
      it "clears the backtrace clean patterns" do
        config.full_backtrace = true
        config.options[:backtrace_clean_patterns].should == []
      end
    end

    describe "debug=true" do
      it "requires 'ruby-debug'" do
        config.should_receive(:require).with('ruby-debug')
        config.debug = true
      end
    end

    describe "debug=false" do
      it "does not require 'ruby-debug'" do
        config.should_not_receive(:require).with('ruby-debug')
        config.debug = false
      end
    end

  end

end
