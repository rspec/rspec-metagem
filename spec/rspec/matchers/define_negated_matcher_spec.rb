module RSpec
  module Matchers
    RSpec.describe 'RSpec::Matchers.define_negated_matcher' do
      RSpec::Matchers.define :my_base_non_negated_matcher do
        match { |actual| actual == foo }

        def foo
          13
        end

        def description
          "my base matcher description"
        end
      end

      shared_examples "making a copy" do |copy_method|
        context "when making a copy via `#{copy_method}`" do
          it "uses a copy of the base matcher" do
            base_matcher = include(3)
            aliased = AliasedNegatedMatcher.new(base_matcher, Proc.new {})
            copy = aliased.__send__(copy_method)

            expect(copy).not_to equal(aliased)
            expect(copy.base_matcher).not_to equal(base_matcher)
            expect(copy.base_matcher).to be_a(RSpec::Matchers::BuiltIn::Include)
            expect(copy.base_matcher.expected).to eq([3])
          end

          it "copies custom matchers properly so they can work even though they have singleton behavior" do
            base_matcher = my_base_non_negated_matcher
            aliased = AliasedNegatedMatcher.new(base_matcher, Proc.new { |a| a })
            copy = aliased.__send__(copy_method)

            expect(copy).not_to equal(aliased)
            expect(copy.base_matcher).not_to equal(base_matcher)

            expect(15).to copy

            expect { expect(13).to copy }.to fail_with(/expected 13/)
          end
        end
      end

      include_examples "making a copy", :dup
      include_examples "making a copy", :clone

      RSpec::Matchers.define_negated_matcher :an_array_excluding, :include
      it_behaves_like "an RSpec matcher", :valid_value => [1, 3], :invalid_value => [1, 2] do
        let(:matcher) { an_array_excluding(2) }
      end

      it 'works properly when composed' do
        list = 1.upto(10).to_a
        expect { list.delete(5) }.to change { list }.to(an_array_excluding 5)
      end

      context 'when no block is passed' do
        RSpec::Matchers.define :be_an_odd_number do
          match { |actual| actual.odd? }
        end
        RSpec::Matchers.define_negated_matcher :be_an_even_number, :be_an_odd_number

        it 'uses the default negated description' do
          expect(be_an_even_number.description).to eq("be an even number")
        end

        context "when matched positively" do
          it 'matches values that fail the original matcher' do
            expect { expect(22).to be_an_odd_number }.to fail_with("expected 22 to be an odd number")
            expect(22).to be_an_even_number
          end

          it "fails matches against values that pass the original matcher" do
            expect(21).to be_an_odd_number
            expect { expect(21).to be_an_even_number }.to fail_with("expected 21 to be an even number")
          end
        end

        context "when matched negatively" do
          it 'matches values that fail the original matcher' do
            expect { expect(21).not_to be_an_odd_number }.to fail_with("expected 21 not to be an odd number")
            expect(21).not_to be_an_even_number
          end

          it "fails matches against values that pass the original matcher" do
            expect(22).not_to be_an_odd_number
            expect { expect(22).not_to be_an_even_number }.to fail_with("expected 22 not to be an even number")
          end
        end
      end

      context 'when the negated description is overriden' do
        RSpec::Matchers.define :be_bigger_than_ten do
          match { |actual| actual > 10 }
        end
        RSpec::Matchers.define_negated_matcher :be_smaller_than_ten, :be_bigger_than_ten do |desc|
          "#{desc.sub('bigger', 'smaller')} (overriden)"
        end

        it 'overrides the description with the provided block' do
          expect(be_smaller_than_ten.description).to eq("be smaller than ten (overriden)")
        end

        it 'overrides the failure message with the provided block' do
          expect { expect(12).to be_smaller_than_ten }.to fail_with("expected 12 to be smaller than ten (overriden)")
        end
      end

      context "for a matcher that has custom `match_when_negated` logic" do
        RSpec::Matchers.define :matcher_with_custom_negation do |match_value|
          match { match_value }
          match_when_negated { |actual| actual == :does_not_match_true }
        end
        RSpec::Matchers.define_negated_matcher :negated_matcher_with_custom_negation, :matcher_with_custom_negation

        it "uses the `match_when_negated` logic for matching" do
          expect(:does_not_match_true).to negated_matcher_with_custom_negation(true)
          expect {
            expect(:does_not_match_false).to negated_matcher_with_custom_negation(true)
          }.to fail
        end

        it "uses the `match` logic for `expect(..).not_to`" do
          expect(:foo).not_to negated_matcher_with_custom_negation(true)
        end
      end
    end
  end
end
