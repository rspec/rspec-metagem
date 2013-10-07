require 'spec_helper'

module RSpec
  module Matchers
    describe Composable do

      context "included in a matcher class" do

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

        [:and, :or].each do |composition_method|

          it "mix the ##{ composition_method } method" do
            expect(minimal_composable_matcher).to respond_to composition_method
          end

          describe "##{composition_method}" do

            it "returns a Composite matcher" do
              composite_matcher = minimal_composable_matcher.send(composition_method, minimal_composable_matcher)
              expect(composite_matcher).to be_kind_of BuiltIn::Composite
            end

          end

        end

      end

    end
  end
end
