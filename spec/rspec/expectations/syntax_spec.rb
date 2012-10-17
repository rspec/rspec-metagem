require 'spec_helper'

module RSpec
  module Expectations
    module Syntax
      describe "the should and should_not expectations" do
        let(:warner) { ::Kernel }

        describe "#should" do
          it "prints a warning when the message object isn't a String" do
            warner.should_receive(:warn).with /ignoring.*message/
            3.should eq(3), :not_a_string
          end

          it "doesn't print a warning when message is a String" do
            warner.should_not_receive(:warn)
            3.should eq(3), "a string"
          end
        end

        describe "#should_not" do
          it "prints a warning when the message object isn't a String" do
            warner.should_receive(:warn).with /ignoring.*message/
            3.should_not eq(4), :not_a_string
          end

          it "doesn't print a warning when message is a String" do
            warner.should_not_receive(:warn)
            3.should_not eq(4), "a string"
          end
        end
      end
    end
  end
end
