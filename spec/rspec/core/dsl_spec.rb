require 'spec_helper'
require 'support/in_sub_process'

main = self

RSpec.describe "The RSpec DSL" do
  include InSubProcess

  methods = [
    :describe,
    :share_examples_for,
    :shared_examples_for,
    :shared_examples,
    :shared_context,
  ]

  methods.each do |method_name|
    describe "##{method_name}" do
      it "is added to the main object and Module when expose_globally is enabled" do
        in_sub_process do
          RSpec.configuration.expose_globally = true
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
  end
end

