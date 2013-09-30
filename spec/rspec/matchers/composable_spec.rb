require 'spec_helper'

module RSpec
  module Matchers
    describe Composable do

      context "when included in a matcher class" do

        let :minimal_composable_matcher do
          Class.new do
            include Composable
            def matches(actual)
              false
            end
            def failure_message_for_should
              "failure message"
            end
          end.new
        end

        describe "#and" do

          it "returns a composite matcher" do
            composite_matcher = minimal_composable_matcher.and(minimal_composable_matcher)
            expect(composite_matcher).to be_kind_of BuiltIn::Composite
          end

          it "can be composed many times" do
            composite_matcher = minimal_composable_matcher.and(minimal_composable_matcher).
              and(minimal_composable_matcher).and(minimal_composable_matcher)
            expect(composite_matcher).to be_kind_of BuiltIn::Composite
          end

        end
      end
    end
  end
end
