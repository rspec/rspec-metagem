require 'spec_helper'

describe "extensions" do
  describe "#debugger" do
    it "warns if ruby-debug is not installed" do
      object = Object.new
      object.should_receive(:warn).with(/debugger .* ignored/)
      object.stub(:require) { raise LoadError }
      object.method_missing(:debugger)
    end
  end
end
