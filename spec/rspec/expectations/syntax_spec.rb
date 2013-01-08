require 'spec_helper'

module RSpec
  module Expectations
    module Syntax
      describe "when passing a message to an expectation" do
        let(:warner) { ::Kernel }

        describe "expect(...).to" do
          it "prints a warning when the message object isn't a String" do
            warner.should_receive(:warn).with /ignoring.*message/
            expect(3).to eq(3), :not_a_string
          end

          it "doesn't print a warning when message is a String" do
            warner.should_not_receive(:warn)
            expect(3).to eq(3), "a string"
          end
        end

        describe "expect(...).to_not" do
          it "prints a warning when the message object isn't a String" do
            warner.should_receive(:warn).with /ignoring.*message/
            expect(3).not_to eq(4), :not_a_string
          end

          it "doesn't print a warning when message is a String" do
            warner.should_not_receive(:warn)
            expect(3).not_to eq(4), "a string"
          end
        end
      end
    end
  end
end
