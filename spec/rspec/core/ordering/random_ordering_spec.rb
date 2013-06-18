require "spec_helper"

module RSpec::Core::Ordering
  describe RandomOrdering do
    it 'shuffles the items randomly' do
      configuration = RSpec::Core::Configuration.new
      configuration.seed = 1234

      strategy = RandomOrdering.new(configuration)
      # 3, 4, 2, 1 is the shuffled order caused by seed 1234.
      expect(strategy.order([1, 2, 3, 4])).to eq([3, 4, 2, 1])
    end

    it 'seeds the random number generator' do
      allow(Kernel).to receive(:srand)
      expect(Kernel).to receive(:srand).with(1234).once

      configuration = RSpec::Core::Configuration.new
      configuration.seed = 1234

      strategy = RandomOrdering.new(configuration)
      strategy.order([1, 2, 3, 4])
    end

    it 'resets random number generation' do
      allow(Kernel).to receive(:srand)
      expect(Kernel).to receive(:srand).with(no_args)

      strategy = RandomOrdering.new
      strategy.order([])
    end

    it 'is considered a built in ordering' do
      expect(RandomOrdering.new).to be_built_in
    end
  end
end
