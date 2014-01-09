require 'spec_helper'
if RUBY_VERSION < '1.9.3'
  require 'complex'
  require 'date'
end

module RSpec
  module Matchers
    describe "eq" do
      it_behaves_like "an RSpec matcher", :valid_value => 1, :invalid_value => 2 do
        let(:matcher) { eq(1) }
      end

      it "is diffable" do
        expect(eq(1)).to be_diffable
      end

      it "matches when actual == expected" do
        expect(1).to eq(1)
      end

      it "does not match when actual != expected" do
        expect(1).not_to eq(2)
      end

      it "compares by sending == to actual (not expected)" do
        called = false
        actual = Class.new do
          define_method :== do |other|
            called = true
          end
        end.new

        expect(actual).to eq :anything # to trigger the matches? method
        expect(called).to be_truthy
      end

      it "describes itself" do
        matcher = eq(1)
        matcher.matches?(1)
        expect(matcher.description).to eq "eq 1"
      end

      it "provides message, expected and actual on #failure_message" do
        matcher = eq("1")
        matcher.matches?(1)
        expect(matcher.failure_message).to eq "\nexpected: \"1\"\n     got: 1\n\n(compared using ==)\n"
      end

      it "provides message, expected and actual on #negative_failure_message" do
        matcher = eq(1)
        matcher.matches?(1)
        expect(matcher.failure_message_when_negated).to eq "\nexpected: value != 1\n     got: 1\n\n(compared using ==)\n"
      end

      it 'fails properly when the actual is an array of multiline strings' do
        expect {
          expect(["a\nb", "c\nd"]).to eq([])
        }.to fail_matching("expected: []")
      end

      describe '#description' do
        [
            [nil, 'eq nil'],
            [true, 'eq true'],
            [false, 'eq false'],
            [:symbol, 'eq :symbol'],
            [1, 'eq 1'],
            [1.2, 'eq 1.2'],
            [Complex(1, 2), "eq #{Complex(1, 2).inspect}"],
            ['foo', 'eq "foo"'],
            [/regex/, 'eq /regex/'],
            [['foo'], 'eq ["foo"]'],
            [{:foo => :bar}, 'eq {:foo=>:bar}'],
            [Class, 'eq Class'],
            [RSpec, 'eq RSpec'],
            [Date.new(2014, 1, 1), "eq #{Date.new(2014, 1, 1).inspect}"],
            [Time.utc(2014, 1, 1), "eq #{Time.utc(2014, 1, 1).inspect}"],
        ].each do |expected, expected_description|
          context "with #{expected.inspect}" do
            it "is \"#{expected_description}\"" do
              expect(eq(expected).description).to eq expected_description
            end
          end
        end

        context 'with object' do
          it 'matches with "^eq #<Object:0x[0-9a-f]*>$"' do
            expect(eq(Object.new).description).to match(/^eq #<Object:0x[0-9a-f]*>$/)
          end
        end
      end
    end
  end
end

