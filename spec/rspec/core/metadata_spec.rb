require 'spec_helper'

module Rspec
  module Core
    describe Metadata do
      describe "[:behaviour][:name]" do
        it "generates name for top level example group" do
          m = Metadata.new
          m.process("description", :caller => caller(0))
          m[:behaviour][:name].should == "description"
        end

        it "concats args to describe()" do
          m = Metadata.new
          m.process(String, "with dots", :caller => caller(0))
          m[:behaviour][:name].should == "String with dots"
        end

        it "concats nested names" do
          m = Metadata.new(:behaviour => {:name => 'parent'})
          m.process(String, "child", :caller => caller(0))
          m[:behaviour][:name].should == "parent child"
        end

        it "strips the name" do
          m = Metadata.new
          m.process("  description  \n", :caller => caller(0))
          m[:behaviour][:name].should == "description"
        end
      end

      describe "[:full_description]" do
        it "concats the behaviour name and description" do
          m = Metadata.new
          m[:behaviour][:name] = "group"

          m = m.for_example("example", {})
          m[:full_description].should == "group example"
        end
      end

      describe "#determine_file_path" do
        it "finds the first spec file in the caller array" do
          m = Metadata.new
          m.process(:caller => [
            "foo",
            "#{__FILE__}:#{__LINE__}",
            "bar_spec.rb:23",
            "baz"
          ])
          m[:behaviour][:file_path].should == __FILE__
        end
      end

      describe "#determine_line_number" do
        it "finds the line number with the first spec file " do
          m = Metadata.new
          m.process(:caller => [
            "foo",
            "#{__FILE__}:#{__LINE__}",
            "bar_spec.rb:23",
            "baz"
          ])
          m[:behaviour][:line_number].should == __LINE__ - 4
        end
        it "uses the number after the first : for ruby 1.9" do
          m = Metadata.new
          m.process(:caller => [
            "foo",
            "#{__FILE__}:#{__LINE__}:999",
            "bar_spec.rb:23",
            "baz"
          ])
          m[:behaviour][:line_number].should == __LINE__ - 4
        end
      end

      describe "#metadata_for_example" do
        let(:caller_for_example) { caller(0) }
        let(:line_number)        { __LINE__ - 1 }
        let(:metadata)           { Metadata.new.process("group description", :caller => caller(0)) }
        let(:mfe)                { metadata.for_example("example description", {:caller => caller_for_example, :arbitrary => :options}) }

        it "stores the description" do
          mfe[:description].should == "example description"
        end

        it "stores the full_description (group description + example description)" do
          mfe[:full_description].should == "group description example description"
        end

        it "creates an empty execution result" do
          mfe[:execution_result].should == {}
        end

        it "stores the caller" do
          mfe[:caller].should == caller_for_example
        end

        it "extracts file path from caller" do
          mfe[:file_path].should == __FILE__ 
        end

        it "extracts line number from caller" do
          mfe[:line_number].should == line_number 
        end

        it "extracts location from caller" do
          mfe[:location].should == "#{__FILE__}:#{line_number}"
        end

        it "merges arbitrary options" do
          mfe[:arbitrary].should == :options 
        end

      end
    end
  end
end
