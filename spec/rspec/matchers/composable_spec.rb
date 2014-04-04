module RSpec
  module Matchers
    RSpec.describe Composable do
      RSpec::Matchers.define :matcher_using_surface_descriptions_in do |expected|
        match { false }
        failure_message { surface_descriptions_in(expected) }
      end

      it 'does not blow up when surfacing descriptions from an unreadable IO object' do
        expect {
          expect(3).to matcher_using_surface_descriptions_in(STDOUT)
        }.to fail_with(STDOUT.inspect)
      end

      RSpec::Matchers.define :all_but_one do |matcher|
        match do |actual|
          match_count = actual.count { |v| values_match?(matcher, v) }
          actual.size == match_count + 1
        end
      end

      RSpec::Matchers.define :have_string_length do |expected|
        match do |actual|
          @actual = actual
          string_length == expected
        end

        def string_length
          @string_length ||= @actual.length
        end
      end

      context "when using a matcher instance that memoizes state multiple times in a composed expression" do
        it "works properly in spite of the memoization" do
          expect(["foo", "bar", "a"]).to all_but_one(have_string_length(3))
        end
      end

      describe "cloning data structures containing matchers" do
        include Composable

        RSpec::Matchers.define :be_a_clone_of do |expected|
          match do |actual|
            !actual.equal?(expected) &&
             actual.class.equal?(expected.class) &&
             state_of(actual) == state_of(expected)
          end

          def state_of(object)
            ivar_names = object.instance_variables
            Hash[ ivar_names.map { |n| [n, object.instance_variable_get(n)] } ]
          end
        end

        it "clones only the contained matchers" do
          matcher_1   = eq(1)
          matcher_2   = eq(2)
          object      = Object.new
          uncloneable = nil

          data_structure = {
            "foo"  => matcher_1,
            "bar"  => [matcher_2, uncloneable],
            "bazz" => object
          }

          cloned = with_matchers_cloned(data_structure)
          expect(cloned).not_to equal(data_structure)

          expect(cloned["foo"]).to be_a_clone_of(matcher_1)
          expect(cloned["bar"].first).to be_a_clone_of(matcher_2)
          expect(cloned["bazz"]).to equal(object)
        end

        it "copies custom matchers properly so they can work even though they have singleton behavior" do
          expect("foo").to with_matchers_cloned(have_string_length 3)
        end

        it 'does not blow up when passed an array containing an IO object' do
          stdout = STDOUT
          expect(with_matchers_cloned([stdout]).first).to equal(stdout)
        end
      end
    end
  end
end
