require 'spec_helper'

module RSpec::Matchers::BuiltIn
  describe Compound do
    context "when used as a composable matcher" do
      it 'can pass' do
        expect(["food", "barn"]).to include(
          a_string_starting_with("f").and(ending_with("d")),
          a_string_starting_with("b").and(ending_with("n"))
        )
      end

      it 'can fail' do
        expect {
          expect(["foo", "bar"]).to include(
            a_string_starting_with("f").and(ending_with("d")),
            a_string_starting_with("b").and(ending_with("n"))
          )
        }.to fail_matching('expected ["foo", "bar"] to include (a string starting with "f" and ending with "d") and (a string starting with "b" and ending with "n")')
      end

      it 'provides a description' do
        matcher = include(
          a_string_starting_with("f").and(ending_with("d")),
          a_string_starting_with("b").and(ending_with("n"))
        )

        expect(matcher.description).to eq('include (a string starting with "f" and ending with "d") and (a string starting with "b" and ending with "n")')
      end
    end

    describe "expect(...).to matcher.and(other_matcher)" do

      it_behaves_like "an RSpec matcher", :valid_value => 3, :invalid_value => 4 do
        let(:matcher) { eq(3).and be <= 3 }
      end

      context 'when both matchers pass' do
        it 'passes' do
          expect(3).to eq(3).and be >= 2
        end
      end

      it 'has a description composed of both matcher descriptions' do
        matcher = eq(3).and be >= 2
        expect(3).to matcher
        expect(matcher.description).to eq("eq 3 and be >= 2")
      end

      context 'when only the first matcher fails' do
        it "fails with the first matcher's failure message" do
          expect {
            expect(3).to eq(4).and be >= 2
          }.to fail_with(dedent <<-EOS)
            |
            |expected: 4
            |     got: 3
            |
            |(compared using ==)
            |
          EOS
        end
      end

      context 'when only the second matcher fails' do
        it "fails with the second matcher's failure message" do
          expect {
            expect(3).to be_kind_of(Integer).and eq(4)
          }.to fail_with(dedent <<-EOS)
            |
            |expected: 4
            |     got: 3
            |
            |(compared using ==)
            |
          EOS
        end
      end

      context "when both mathers fail" do
        context "when both matchers have multi-line failure messages" do
          it 'fails with a well formatted message containing both sub-messages' do
            expect {
              expect(3).to eq(4).and be >= 8
            }.to fail_with(dedent <<-EOS)
              |
              |   expected: 4
              |        got: 3
              |
              |   (compared using ==)
              |
              |...and:
              |
              |   expected: >= 8
              |        got:    3
            EOS
          end
        end

        context "when both matchers have single-line failure messages" do
          it 'fails with a single-line failure message' do
            expect {
              expect("foo").to start_with("a").and end_with("z")
            }.to fail_with('expected "foo" to start with "a" and expected "foo" to end with "z"')
          end
        end

        context "when the first matcher has a multi-line failure message" do
          it 'fails with a well formatted message containing both sub-messages' do
            expect {
              expect("foo").to eq(4).and end_with("z")
            }.to fail_with(dedent <<-EOS)
              |
              |   expected: 4
              |        got: "foo"
              |
              |   (compared using ==)
              |
              |...and:
              |
              |   expected "foo" to end with "z"
            EOS
          end
        end

        context "when the second matcher has a multi-line failure message" do
          it 'fails with a well formatted message containing both sub-messages' do
            expect {
              expect("foo").to end_with("z").and eq(4)
            }.to fail_with(dedent <<-EOS)
              |   expected "foo" to end with "z"
              |
              |...and:
              |
              |   expected: 4
              |        got: "foo"
              |
              |   (compared using ==)
              |
            EOS
          end
        end
      end
    end

    describe "expect(...).not_to matcher.and(other_matcher)" do
      it "is not supported" do
        expect {
          expect(3).not_to eq(2).and be > 2
        }.to raise_error(NotImplementedError, /matcher.and matcher` is not supported/)
      end
    end

    describe "expect(...).to matcher.or(other_matcher)" do
      it_behaves_like "an RSpec matcher", :valid_value => 3, :invalid_value => 5 do
        let(:matcher) { eq(3).or eq(4) }
      end

      it 'has a description composed of both matcher descriptions' do
        matcher = eq(3).or eq(4)
        expect(3).to matcher
        expect(matcher.description).to eq("eq 3 or eq 4")
      end

      context 'when both matchers pass' do
        it 'passes' do
          expect("foo").to start_with("f").or end_with("o")
        end
      end

      context 'when only the first matcher passes' do
        it 'passes' do
          expect("foo").to start_with("f").or end_with("z")
        end
      end

      context 'when only the last matcher passes' do
        it 'passes' do
          expect("foo").to start_with("a").or end_with("o")
        end
      end

      context 'when both matchers fail' do
        context "when both matchers have multi-line failure messages" do
          it 'fails with a well formatted message containing both sub-messages' do
            expect {
              expect(3).to eq(4).or be >= 8
            }.to fail_with(dedent <<-EOS)
              |
              |   expected: 4
              |        got: 3
              |
              |   (compared using ==)
              |
              |...or:
              |
              |   expected: >= 8
              |        got:    3
            EOS
          end
        end

        context "when both matchers have single-line failure messages" do
          it 'fails with a single-line failure message' do
            expect {
              expect("foo").to start_with("a").or end_with("z")
            }.to fail_with('expected "foo" to start with "a" or expected "foo" to end with "z"')
          end
        end

        context "when the first matcher has a multi-line failure message" do
          it 'fails with a well formatted message containing both sub-messages' do
            expect {
              expect("foo").to eq(4).or end_with("z")
            }.to fail_with(dedent <<-EOS)
              |
              |   expected: 4
              |        got: "foo"
              |
              |   (compared using ==)
              |
              |...or:
              |
              |   expected "foo" to end with "z"
            EOS
          end
        end

        context "when the second matcher has a multi-line failure message" do
          it 'fails with a well formatted message containing both sub-messages' do
            expect {
              expect("foo").to end_with("z").or eq(4)
            }.to fail_with(dedent <<-EOS)
              |   expected "foo" to end with "z"
              |
              |...or:
              |
              |   expected: 4
              |        got: "foo"
              |
              |   (compared using ==)
              |
            EOS
          end
        end
      end
    end

    context "when chaining many matchers together" do
      it 'can pass appropriately' do
        matcher = start_with("f").and end_with("z").or end_with("o")
        expect("foo").to matcher
        expect(matcher.description).to eq('start with "f" and end with "z" or end with "o"')
      end

      it 'fails with a complete message' do
        expect {
          expect(3).to eq(1).and eq(2).and eq(3).and eq(4)
        }.to fail_with(dedent <<-EOS)
          |
          |   expected: 1
          |        got: 3
          |
          |   (compared using ==)
          |
          |...and:
          |
          |      expected: 2
          |           got: 3
          |
          |      (compared using ==)
          |
          |   ...and:
          |
          |      expected: 4
          |           got: 3
          |
          |      (compared using ==)
          |
        EOS
      end
    end

    describe "expect(...).not_to matcher.or(other_matcher)" do
      it "is not supported" do
        expect {
          expect(3).not_to eq(2).or be > 2
        }.to raise_error(NotImplementedError, /matcher.or matcher` is not supported/)
      end
    end
  end
end
