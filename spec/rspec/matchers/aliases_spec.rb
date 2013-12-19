require 'spec_helper'

module RSpec
  describe Matchers, "aliases" do
    matcher :be_aliased_to do |old_matcher|
      chain :with_description do |desc|
        @expected_desc = desc
      end

      match do |aliased_matcher|
        @actual_desc = aliased_matcher.description

        aliased_matcher.base_matcher.class == old_matcher.class &&
        @actual_desc == @expected_desc
      end

      failure_message do |aliased_matcher|
        "expected #{aliased_matcher} to be aliased to #{old_matcher} with " +
        "description: #{@expected_desc.inspect}, but got #{@actual_desc.inspect}"
      end

      description do |aliased_matcher|
        "have an alias for #{old_matcher.description.inspect} with description: #{@expected_desc.inspect}"
      end
    end

    specify {
      expect(
        a_value_within(0.1).of(3)
      ).to be_aliased_to(
        be_within(0.1).of(3)
      ).with_description("a value within 0.1 of 3")
    }

    specify {
      expect(
        a_value_including("a")
      ).to be_aliased_to(
        include("a")
      ).with_description('a value including "a"')
    }

    specify {
      expect(
        a_string_matching(/foo/)
      ).to be_aliased_to(
        match(/foo/)
      ).with_description('a string matching /foo/')
    }
  end
end
