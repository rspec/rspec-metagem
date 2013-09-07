require "spec_helper"

module RSpec::Core::Ordering
  describe Identity do
    it "does not affect the ordering of the items" do
      expect(Identity.new.order([1, 2, 3])).to eq([1, 2, 3])
    end

    it 'is considered a built in ordering' do
      expect(Identity.new).to be_built_in
    end
  end

  describe Random do
    it 'shuffles the items randomly' do
      configuration = RSpec::Core::Configuration.new
      configuration.seed = 1234

      strategy = Random.new
      # 3, 4, 2, 1 is the shuffled order caused by seed 1234.
      expect(strategy.order([1, 2, 3, 4], configuration)).to eq([3, 4, 2, 1])
    end

    it 'seeds the random number generator' do
      allow(Kernel).to receive(:srand)
      expect(Kernel).to receive(:srand).with(1234).once

      configuration = RSpec::Core::Configuration.new
      configuration.seed = 1234

      strategy = Random.new
      strategy.order([1, 2, 3, 4], configuration)
    end

    it 'resets random number generation' do
      allow(Kernel).to receive(:srand)
      expect(Kernel).to receive(:srand).with(no_args)

      strategy = Random.new
      strategy.order([])
    end

    it 'is considered a built in ordering' do
      expect(Random.new).to be_built_in
    end
  end

  describe Custom do
    it 'uses the block to order the list' do
      strategy = Custom.new(proc { |list| list.reverse })

      expect(strategy.order([1, 2, 3, 4])).to eq([4, 3, 2, 1])
    end

    it 'is not considered a built in ordering' do
      expect(Custom.new(proc { })).not_to be_built_in
    end
  end

  describe Registry do
    let(:configuration) { double("configuration") }
    subject { Registry.new(configuration) }

    describe "#resolve_example_ordering" do
      it "gives the default ordering" do
        expect(subject.resolve_example_ordering).to be_an_instance_of(Identity)
      end

      it "gives a callable ordering when called with a callable" do
        expect(subject.resolve_example_ordering(proc { :hi })).to be_a_kind_of(Custom)
      end

      it "gives the registered ordering when called with a symbol" do
        ordering = Object.new
        subject.register(:falcon, ordering)

        expect(subject.resolve_example_ordering(:falcon)).to be ordering
      end

      it "gives me the global one when I call it with an unknown symbol" do
        expect(subject.resolve_example_ordering(:falcon)).to be_an_instance_of(Identity)
      end
    end

    describe "#resolve_group_ordering" do
      it "gives the default ordering" do
        expect(subject.resolve_group_ordering).to be_an_instance_of(Identity)
      end

      it "gives a callable ordering when called with a callable" do
        expect(subject.resolve_group_ordering(proc { :hi })).to be_a_kind_of(Custom)
      end

      it "gives the registered ordering when called with a symbol" do
        ordering = Object.new
        subject.register(:falcon, ordering)

        expect(subject.resolve_group_ordering(:falcon)).to be ordering
      end

      it "gives me the global one when I call it with an unknown symbol" do
        expect(subject.resolve_group_ordering(:falcon)).to be_an_instance_of(Identity)
      end
    end
  end
end
