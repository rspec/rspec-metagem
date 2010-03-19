require 'spec_helper'
require 'stringio'

describe Rspec::Core::Formatters::Helpers do
  let(:helper) { helper = Object.new.extend(Rspec::Core::Formatters::Helpers) }

  describe "format seconds" do
    pending "uses passed in precision if specified" do
      # can't get regex right to handle this case where we don't want it to consume all zeroes
      helper.format_seconds(0.00005, 2).should == "0.00"
    end
    
    context "sub second times" do
      it "returns 5 digits of precision" do
        helper.format_seconds(0.000005).should == "0.00001"
      end

      it "strips off trailing zeroes" do
        helper.format_seconds(0.02000).should == "0.02"
      end
    end

    context "second and greater times" do

      it "returns 2 digits of precision" do
        helper.format_seconds(50.330340).should == "50.33"
      end

      it "returns human friendly elasped time" do
        helper.format_seconds(50.1).should == "50.1"
        helper.format_seconds(5).should == "5"
        helper.format_seconds(5.0).should == "5"
      end
    end    
  end

  
end