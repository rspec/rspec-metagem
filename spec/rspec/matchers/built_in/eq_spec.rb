require 'spec_helper'
require 'date'
require 'complex'

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

      context "Time Equality" do
        RSpec::Matchers.define :a_string_with_differing_output do
          match do |string|
            time_strings = /expected: (.+)\n.*got: (.+)$/.match(string).captures
            time_strings.uniq.count == 2
          end
        end

        RSpec::Matchers.define :a_string_with_identical_output do
          match do |string|
            time_strings = /expected: value != (.+)\n.*got: (.+)$/.match(string).captures
            time_strings.uniq.count == 1
          end
        end

        context 'with Time objects' do
          let(:time1) { Time.utc(1969, 12, 31, 19, 01, 40, 101) }
          let(:time2) { Time.utc(1969, 12, 31, 19, 01, 40, 102) }

          it 'produces different output for Times differing by milliseconds' do
            expect {
              expect(time1).to eq(time2)
            }.to fail_with(a_string_with_differing_output)
          end
        end

        context 'with DateTime objects' do
          let(:date1) { DateTime.new(2000, 1, 1, 1, 1, Rational(1, 10)) }
          let(:date2) { DateTime.new(2000, 1, 1, 1, 1, Rational(2, 10)) }

          it 'produces different output for DateTimes differing by milliseconds' do
            expect {
              expect(date1).to eq(date2)
            }.to fail_with(a_string_with_differing_output)
          end

          it 'does not not assume DateTime is defined since you need to require `date` to make it available' do
            hide_const('DateTime')
            expect {
              expect(5).to eq(4)
            }.to raise_error(RSpec::Expectations::ExpectationNotMetError)
          end

          it 'fails with identical output when the DateTimes are exactly the same' do
            expect {
              expect(date1).to_not eq(date1)
            }.to fail_with(a_string_with_identical_output)
          end

          context 'when ActiveSupport is loaded' do
            it "uses a custom format to ensure the output is different when DateTimes differ" do
              stub_const("ActiveSupport", Module.new)
              allow(date1).to receive(:inspect).and_return("Timestamp")
              allow(date2).to receive(:inspect).and_return("Timestamp")

              expect {
                expect(date1).to eq(date2)
              }.to fail_with(a_string_with_differing_output)
            end
          end
        end
      end
    end
  end
end
