require 'spec_helper'

RSpec.describe "an example" do
  FailInSkip = Class.new(RuntimeError)
  FailAfterSkip = Class.new(RuntimeError)

  context 'with a skipped block' do
    def run_example(*args)
      group = RSpec::Core::ExampleGroup.describe('group') do
        it "does something" do
          skip(*args) { raise FailInSkip }
          raise FailAfterSkip
        end
      end

      example = group.examples.first
      example.run(group.new, double.as_null_object)
      example
    end

    it 'allows the example to continue executing' do
      expect(run_example).to fail_with(FailAfterSkip)
    end

    context "when given a truthy :if option" do
      it 'allows the example to continue executing' do
        expect(run_example(:if => true)).to fail_with(FailAfterSkip)
      end
    end

    context "when given a falsey :if option" do
      it "does not skip the block" do
        expect(run_example(:if => false)).to fail_with(FailInSkip)
      end
    end

    context "when given a truthy :unless option" do
      it "does not skip the block" do
        expect(run_example(:unless => true)).to fail_with(FailInSkip)
      end
    end

    context "when given a falsey :unless option" do
      it 'allows the example to continue executing' do
        expect(run_example(:unless => false)).to fail_with(FailAfterSkip)
      end
    end
  end
end
