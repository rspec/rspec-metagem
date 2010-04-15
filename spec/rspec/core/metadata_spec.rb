require 'spec_helper'

module Rspec
  module Core
    describe Metadata do

      describe "process" do
        Metadata::RESERVED_KEYS.each do |key|
          it "prohibits :#{key} as a hash key" do
            m = Metadata.new
            expect do
              m.process('group', key => {})
            end.to raise_error(/:#{key} is not allowed/)
          end
        end
      end

      describe "description" do
        it "just has the example description" do
          m = Metadata.new
          m.process('group')

          m = m.for_example("example", {})
          m[:description].should == "example"
        end
      end

      describe "full description" do
        it "concats the example group name and description" do
          m = Metadata.new
          m.process('group')

          m = m.for_example("example", {})
          m[:full_description].should == "group example"
        end
      end

      describe "description" do
        context "with a string" do
          it "provides the submitted description" do
            m = Metadata.new
            m.process('group')

            m[:example_group][:description].should == "group"
          end
        end

        context "with a non-string" do
          it "provides the submitted description" do
            m = Metadata.new
            m.process('group')

            m[:example_group][:description].should == "group"
          end
        end

        context "with a non-string and a string" do
          it "concats the args" do
            m = Metadata.new
            m.process(Object, 'group')

            m[:example_group][:description].should == "Object group"
          end
        end
      end

      describe "full description" do
        it "concats the nested example group descriptions" do
          parent = Metadata.new
          parent.process(Object, 'parent')

          child = Metadata.new(parent)
          child.process('child')

          child[:example_group][:full_description].should == "Object parent child"
        end
      end

      describe "file path" do
        it "finds the first spec file in the caller array" do
          m = Metadata.new
          m.process(:caller => [
            "foo",
            "#{__FILE__}:#{__LINE__}",
            "bar_spec.rb:23",
            "baz"
          ])
          m[:example_group][:file_path].should == __FILE__
        end
        it "is nil if there are no spec files found", :full_backtrace => true do
          m = Metadata.new
          m.process(:caller => [
            "foo",
            "metadata_example.rb:#{__LINE__}",
            "baz"
          ])
          m[:example_group][:file_path].should be_nil
        end
      end

      describe "line number" do
        it "finds the line number with the first spec file " do
          m = Metadata.new
          m.process(:caller => [
            "foo",
            "#{__FILE__}:#{__LINE__}",
            "bar_spec.rb:23",
            "baz"
          ])
          m[:example_group][:line_number].should == __LINE__ - 4
        end
        it "uses the number after the first : for ruby 1.9" do
          m = Metadata.new
          m.process(:caller => [
            "foo",
            "#{__FILE__}:#{__LINE__}:999",
            "bar_spec.rb:23",
            "baz"
          ])
          m[:example_group][:line_number].should == __LINE__ - 4
        end
      end

      describe "metadata for example" do
        let(:caller_for_example) { caller(0) }
        let(:line_number)        { __LINE__ - 1 }
        let(:metadata)           { Metadata.new.process("group description") }
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

        it "points :example_group to the same hash object" do
          a = metadata.for_example("foo", {})[:example_group]
          b = metadata.for_example("bar", {})[:example_group]
          a[:description] = "new description"
          b[:description].should == "new description"
        end
      end

      describe "apply_condition" do
        let(:group_metadata) { Metadata.new.process('group', :caller => ["foo_spec.rb:#{__LINE__}"]) }
        let(:group_line_number) { __LINE__ -1 }
        let(:example_metadata) { group_metadata.for_example('example', :caller => ["foo_spec.rb:#{__LINE__}"]) }
        let(:example_line_number) { __LINE__ -1 }

        it "matches when the line_number matches the group" do
          group_metadata.apply_condition(:line_number, group_line_number).should be_true
        end

        it "matches when the line_number matches the example" do
          example_metadata.apply_condition(:line_number, example_line_number).should be_true
        end
      end

    end
  end
end
