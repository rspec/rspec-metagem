require 'spec_helper'

module RSpec
  module Expectations
    module Syntax
      describe "the should and should_not expectations" do
        describe "#should" do
          it "raises an error when the message object isn't a String" do
            ::Kernel.should_receive(:warn).with /The value passed as the message/
            3.should eq(3), :not_a_string
          end

          it "doesn't raise an error when message is a String" do
            ::Kernel.should_not_receive(:warn).with /The value passed as the message/
            3.should eq(3), "a string"
          end
        end

        describe "#should_not" do
          it "raises an error when the message object isn't a String" do
            ::Kernel.should_receive(:warn).with /The value passed as the message/
            3.should_not eq(4), :not_a_string
          end

          it "doesn't raise an error when message is a String" do
            ::Kernel.should_not_receive(:warn).with /The value passed as the message/
            3.should_not eq(4), "a string"
          end
        end
      end
    end
  end
end
