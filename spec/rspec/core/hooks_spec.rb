require "spec_helper"

module RSpec::Core
  describe Hooks do
    describe "#around" do
      context "when not running the example within the around block" do
        it "does not run the example" do
          examples = []
          group = ExampleGroup.describe do
            around do |example|
            end
            it "foo" do
              examples << self
            end
          end
          group.run
          examples.should have(0).example
        end
      end

      context "when running the example within the around block" do
        it "runs the example" do
          examples = []
          group = ExampleGroup.describe do
            around do |example|
              example.run
            end
            it "foo" do
              examples << self
            end
          end
          group.run
          examples.should have(1).example
        end
      end

      context "when running the example within a block passed to a method" do
        it "runs the example" do
          examples = []
          group = ExampleGroup.describe do
            def yielder
              yield
            end
            around do |example|
              yielder { example.run }
            end
            it "foo" do
              examples << self
            end
          end
          group.run
          examples.should have(1).example
        end
      end

      describe Hooks::Hook do
        it "requires a block" do
          lambda {
            Hooks::BeforeHook.new :foo => :bar
          }.should raise_error "no block given for 'before' hook"
        end
      end
    end
  end
end
