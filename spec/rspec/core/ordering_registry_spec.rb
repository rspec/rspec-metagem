require "spec_helper"

module RSpec::Core
  describe OrderingRegistry do
    let(:configuration) { double("configuration") }
    subject { OrderingRegistry.new(configuration) }

    describe "#resolve_example_ordering" do
      it "gives the default ordering" do
        expect(subject.resolve_example_ordering).to be_an_instance_of(Ordering::IdentityOrdering)
      end

      it "gives a callable ordering when called with a callable" do
        expect(subject.resolve_example_ordering(proc { :hi })).to be_a_kind_of(Ordering::CustomOrdering)
      end

      it "gives the registered ordering when called with a symbol" do
        ordering = Object.new
        subject.register(:falcon, ordering)

        expect(subject.resolve_example_ordering(:falcon)).to be ordering
      end

      it "gives me the global one when I call it with an unknown symbol" do
        expect(subject.resolve_example_ordering(:falcon)).to be_an_instance_of(Ordering::IdentityOrdering)
      end
    end

    describe "#resolve_group_ordering" do
      it "gives the default ordering" do
        expect(subject.resolve_group_ordering).to be_an_instance_of(Ordering::IdentityOrdering)
      end

      it "gives a callable ordering when called with a callable" do
        expect(subject.resolve_group_ordering(proc { :hi })).to be_a_kind_of(Ordering::CustomOrdering)
      end

      it "gives the registered ordering when called with a symbol" do
        ordering = Object.new
        subject.register(:falcon, ordering)

        expect(subject.resolve_group_ordering(:falcon)).to be ordering
      end

      it "gives me the global one when I call it with an unknown symbol" do
        expect(subject.resolve_group_ordering(:falcon)).to be_an_instance_of(Ordering::IdentityOrdering)
      end
    end
  end
end
