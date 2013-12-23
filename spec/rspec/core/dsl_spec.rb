require 'spec_helper'
require 'support/in_sub_process'

main = self

RSpec.describe "The RSpec DSL" do
  include InSubProcess

  shared_examples_for "a dsl method" do
    it "is added to the main object and Module when expose_dsl_globally is enabled" do
      in_sub_process do
        RSpec.configuration.expose_dsl_globally = true
        expect(main).to respond_to(method_name)
        expect(Module.new).to respond_to(method_name)
      end
    end

    it "is added to the RSpec DSL" do
      expect(::RSpec).to respond_to(method_name)
    end

    it "is not added to every object in the system" do
      expect(Object.new).not_to respond_to(method_name)
    end
  end

  methods = [
    :example_group,
    :describe,
    :context,
    :share_examples_for,
    :shared_examples_for,
    :shared_examples,
    :shared_context,
  ]

  methods.each do |method_name|
    describe "##{method_name}" do
      let(:method_name) { method_name }
      it_behaves_like "a dsl method"
    end
  end

  describe "a custom example_group alias" do
    before(:all) { RSpec.configuration.alias_example_group_to(:detail) }

    let(:method_name) { :detail }
    it_behaves_like "a dsl method"
  end
end

