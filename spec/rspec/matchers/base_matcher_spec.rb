require 'spec_helper'

module RSpec::Matchers::BuiltIn
  describe BaseMatcher do
    describe "#match_unless_raises" do
      let(:matcher) do
        Class.new(BaseMatcher).new
      end

      it "returns true if there are no errors" do
        expect(matcher.match_unless_raises {}).to be_truthy
      end

      it "returns false if there is an error" do
        expect(matcher.match_unless_raises { raise }).to be_falsey
      end

      it "returns false if the only submitted error is raised" do
        expect(matcher.match_unless_raises(RuntimeError){ raise "foo" }).to be_falsey
      end

      it "returns false if any of several errors submitted is raised" do
        expect(matcher.match_unless_raises(RuntimeError, ArgumentError, NameError) { raise "foo" }).to be_falsey
        expect(matcher.match_unless_raises(RuntimeError, ArgumentError, NameError) { raise ArgumentError.new('') }).to be_falsey
        expect(matcher.match_unless_raises(RuntimeError, ArgumentError, NameError) { raise NameError.new('') }).to be_falsey
      end

      it "re-raises any error other than one of those specified" do
        expect do
          matcher.match_unless_raises(ArgumentError){ raise "foo" }
        end.to raise_error
      end

      it "stores the rescued exception for use in messages" do
        matcher.match_unless_raises(RuntimeError){ raise "foo" }
        expect(matcher.rescued_exception).to be_a(RuntimeError)
        expect(matcher.rescued_exception.message).to eq("foo")
      end

    end

    describe "#failure_message" do
      context "when the parameter to .new is omitted" do
        it "describes what was expected" do
          matcher_class = Class.new(BaseMatcher) do
            def name=(name)
              @name = name
            end

            def match(expected, actual)
              false
            end
          end

          matcher = matcher_class.new
          matcher.name = "be something"
          matcher.matches?("foo")
          expect(matcher.failure_message).to eq('expected "foo" to be something')
        end
      end
    end

    describe "#===" do
      it "responds the same way as matches?" do
        matcher = Class.new(BaseMatcher) do
          def initialize(expected)
            @expected = expected
          end

          def matches?(actual)
            (@actual = actual) == @expected
          end
        end

        expect(matcher.new(3).matches?(3)).to be_truthy
        expect(matcher.new(3)).to be === 3

        expect(matcher.new(3).matches?(4)).to be_falsey
        expect(matcher.new(3)).not_to be === 4
      end
    end
  end
end
