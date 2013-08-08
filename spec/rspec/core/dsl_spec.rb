require 'spec_helper'

main = self

RSpec.describe "The RSpec DSL" do
  methods = [
    :describe,
    :share_examples_for,
    :shared_examples_for,
    :shared_examples,
    :shared_context,
  ]

  methods.each do |method_name|
    describe "##{method_name}" do
      it "is added to the main object and Module when monkey patching is enabled" do
        pending "how do we sandbox this?"
        RSpec.configuration { |c| c.expose_globally = true }
        expect(main).to respond_to(method_name)
        expect(Module.new).to respond_to(method_name)
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

