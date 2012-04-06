require 'spec_helper'
require 'rspec/core/formatters/snippet_extractor'

module RSpec
  module Core
    module Formatters
      describe SnippetExtractor do
        it "falls back on a default message when it doesn't understand a line" do
          RSpec::Core::Formatters::SnippetExtractor.new.snippet_for("blech").should eq(["# Couldn't get snippet for blech", 1])
        end

        it "falls back on a default message when it doesn't find the file" do
         RSpec::Core::Formatters::SnippetExtractor.new.lines_around("blech", 8).should eq("# Couldn't get snippet for blech")
        end

        it "falls back on a default message when it gets a security error" do
          Thread.new {
            $SAFE = 3
            $SAFE.should == 3
            RSpec::Core::Formatters::SnippetExtractor.new.lines_around("blech", 8).should eq("# Couldn't get snippet for blech")
          }.run
          $SAFE.should == 0
        end
      end
    end
  end
end
