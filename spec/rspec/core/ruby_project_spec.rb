require 'spec_helper'

module RSpec
  module Core
    RSpec.describe RubyProject do

      describe "#determine_root" do

        context "with ancestor containing spec directory" do
          it "returns ancestor containing the spec directory" do
            allow(RubyProject).to receive(:ascend_until).and_return('foodir')
            expect(RubyProject.determine_root).to eq("foodir")
          end
        end

        context "without ancestor containing spec directory" do
          it "returns current working directory" do
            allow(RubyProject).to receive(:find_first_parent_containing).and_return(nil)
            expect(RubyProject.determine_root).to eq(".")
          end
        end

      end
    end
  end
end
