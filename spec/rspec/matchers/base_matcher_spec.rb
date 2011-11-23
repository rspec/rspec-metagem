require "spec_helper"

describe "base matcher" do
  describe "#match_unless_raises" do
    context "with an assertion" do
      let(:mod) do
        Module.new do
          def assert_equal(a,b)
            a == b ? nil : (raise UnexpectedError.new("#{b} does not equal #{a}"))
          end
        end
      end
      let(:matcher) do
        m = mod
        Class.new do
          include BaseMatcher
          extend m
          match_unless_raises UnexpectedError do
            assert_equal expected, actual
          end
        end
      end

      context "with passing assertion" do
        it "passes" do
          matcher.matches?(4).should be_true
        end
      end

      context "with failing assertion" do
        it "fails" do
          matcher.matches?(5).should be_false
        end

        it "provides the raised exception" do
          matcher.matches?(5)
          matcher.rescued_exception.message.
            should eq("5 does not equal 4")
        end
      end
    end

    context "with an unexpected error" do
      let(:matcher) do
        RSpec::Matchers::Matcher.new :foo, :bar do |expected|
          match_unless_raises SyntaxError do |actual|
            raise "unexpected exception"
          end
        end
      end

      it "raises the error" do
        expect do
          matcher.matches?(:bar)
        end.to raise_error("unexpected exception")
      end
    end

  end
end
