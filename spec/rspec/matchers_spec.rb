require 'spec_helper'

main = self
describe RSpec::Matchers do
  include ::RSpec::Support::InSubProcess

  it 'can be mixed into `main`' do
    in_sub_process do
      main.instance_eval do
        include RSpec::Matchers
        expect(3).to eq(3)
        expect(3).to be_odd

        expect {
          expect(4).to be_zero
        }.to fail_with("expected zero? to return true, got false")
      end
    end
  end
end

module RSpec
  module Matchers
    describe "built in matchers" do
      let(:matchers) do
        BuiltIn.constants.map { |n| BuiltIn.const_get(n) }.select do |m|
          m.method_defined?(:matches?) && m.method_defined?(:failure_message)
        end
      end

      specify "they all have defined #=== so they can be composable" do
        missing_threequals = matchers.select do |m|
          m.instance_method(:===).owner == ::Kernel
        end

        # This spec is merely to make sure we don't forget to make
        # a built-in matcher implement `===`. It doesn't check the
        # semantics of that. Use the "an RSpec matcher" shared
        # example group to actually check the semantics.
        expect(missing_threequals).to eq([])
      end

      specify "they all have defined #and and #or so they support compound expectations" do
        noncompound_matchers = matchers.reject do |m|
          m.method_defined?(:and) || m.method_defined?(:or)
        end

        expect(noncompound_matchers).to eq([])
      end

      shared_examples_for "a well-behaved method_missing hook" do
        include MinitestIntegration

        it "raises a NoMethodError (and not SystemStackError) for an undefined method" do
          with_minitest_loaded do
            expect { subject.some_undefined_method }.to raise_error(NoMethodError)
          end
        end
      end

      describe "RSpec::Matchers method_missing hook" do
        subject { self }

        it_behaves_like "a well-behaved method_missing hook"

        context 'when invoked in a Minitest::Test' do
          subject { Minitest::Test.allocate }
          it_behaves_like "a well-behaved method_missing hook"
        end
      end
    end
  end
end

