require 'spec_helper'

describe "extensions" do
  describe "#debugger" do
    it "warns if ruby-debug is not installed" do
      object = Object.new
      object.should_receive(:warn).with(/debugger .* ignored:\n.* ruby-debug/m)
      object.stub(:require) { raise LoadError }
      object.__send__ :method_missing, :debugger
    end
  end
end
