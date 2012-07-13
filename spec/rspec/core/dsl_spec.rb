require 'spec_helper'

main = self
shared_examples_for "a DSL method" do |method_name|
  it 'is available on the main object' do
    main.should respond_to(method_name)
  end

  it "is available on modules (so #{method_name} can be used in a module)" do
    Module.new.should respond_to(method_name)
  end

  it 'is not available on other types of objects' do
    Object.new.should_not respond_to(method_name)
  end
end

describe "The RSpec DSL" do
  methods = [
    :describe,
    :share_examples_for,
    :shared_examples_for,
    :shared_examples,
    :shared_context,
    :share_as
  ]

  methods.each do |meth|
    describe "##{meth}" do
      include_examples "a DSL method", meth
    end
  end
end

