require 'spec_helper'

main = self

describe "The RSpec DSL" do
  methods = [
    :describe,
    :share_examples_for,
    :shared_examples_for,
    :shared_examples,
    :shared_context,
    :share_as
  ]

  methods.each do |method_name|
    describe "##{method_name}" do
      it "is not added to every object in the system" do
        main.should respond_to(method_name)
        Module.new.should respond_to(method_name)
        Object.new.should_not respond_to(method_name)
      end
    end
  end
end

