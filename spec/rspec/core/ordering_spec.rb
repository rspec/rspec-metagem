require "spec_helper"

module RSpec
  module Core
    module Ordering
      RSpec.describe Identity do
        it "does not affect the ordering of the items" do
          expect(Identity.new.order([1, 2, 3])).to eq([1, 2, 3])
        end
      end

      RSpec.describe Random do
        describe '.order' do
          subject { described_class.new(configuration) }

          let(:configuration)  { RSpec::Core::Configuration.new }
          let(:items)          { 10.times.map { |n| n } }
          let(:shuffled_items) { subject.order items }

          it 'shuffles the items randomly' do
            expect(shuffled_items).to match_array items
            expect(shuffled_items).to_not eq items
          end

          context 'given multiple calls' do
            it 'returns the items in the same order' do
              expect(subject.order(items)).to eq shuffled_items
            end
          end

          context 'given randomization has been seeded explicitly' do
            before { @seed = srand }
            after  { srand @seed }

            it "does not affect the global random number generator" do
              srand 123
              val1, val2 = rand(1_000), rand(1_000)

              subject

              srand 123
              subject.order items
              expect(rand(1_000)).to eq(val1)
              subject.order items
              expect(rand(1_000)).to eq(val2)
            end
          end
        end
      end

      RSpec.describe Custom do
        it 'uses the block to order the list' do
          strategy = Custom.new(proc { |list| list.reverse })

          expect(strategy.order([1, 2, 3, 4])).to eq([4, 3, 2, 1])
        end
      end

      RSpec.describe Registry do
        let(:configuration) { Configuration.new }
        subject(:registry) { Registry.new(configuration) }

        describe "#used_random_seed?" do
          it 'returns false if the random orderer has not been used' do
            expect(registry.used_random_seed?).to be false
          end

          it 'returns false if the random orderer has been fetched but not used' do
            expect(registry.fetch(:random)).to be_a(Random)
            expect(registry.used_random_seed?).to be false
          end

          it 'returns true if the random orderer has been used' do
            registry.fetch(:random).order([1, 2])
            expect(registry.used_random_seed?).to be true
          end
        end

        describe "#fetch" do
          it "gives the registered ordering when called with a symbol" do
            ordering = Object.new
            subject.register(:falcon, ordering)

            expect(subject.fetch(:falcon)).to be ordering
          end

          context "when given an unrecognized symbol" do
            it 'invokes the given block and returns its value' do
              expect(subject.fetch(:falcon) { :fallback }).to eq(:fallback)
            end

            it 'raises an error if no block is given' do
              expect {
                subject.fetch(:falcon)
              }.to raise_error(IndexError)
            end
          end
        end
      end
    end
  end
end
