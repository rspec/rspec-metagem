require 'spec_helper'

module RSpec
  describe Matchers, "aliases" do
    matcher :be_aliased_to do |old_matcher|
      chain :with_description do |desc|
        @expected_desc = desc
      end

      match do |aliased_matcher|
        @actual_desc = aliased_matcher.description

        @actual_desc == @expected_desc &&
        aliased_matcher.base_matcher.class == old_matcher.class
      end

      failure_message do |aliased_matcher|
        "expected #{aliased_matcher} to be aliased to #{old_matcher} with " +
        "description: #{@expected_desc.inspect}, but got #{@actual_desc.inspect}"
      end

      description do |aliased_matcher|
        "have an alias for #{old_matcher.description.inspect} with description: #{@expected_desc.inspect}"
      end
    end

    specify do
      expect(a_truthy_value).to be_aliased_to(be_truthy).with_description("a truthy value")
    end

    specify do
      expect(a_falsey_value).to be_aliased_to(be_falsey).with_description("a falsey value")
    end

    specify do
      expect(be_falsy).to be_aliased_to(be_falsey).with_description("be falsy")
    end

    specify do
      expect(a_falsy_value).to be_aliased_to(be_falsey).with_description("a falsy value")
    end

    specify do
      expect(a_nil_value).to be_aliased_to(be_nil).with_description("a nil value")
    end

    specify do
      expect(a_value > 3).to be_aliased_to(be > 3).with_description("a value > 3")
    end

    specify do
      expect(a_value < 3).to be_aliased_to(be < 3).with_description("a value < 3")
    end

    specify do
      expect(a_value <= 3).to be_aliased_to(be <= 3).with_description("a value <= 3")
    end

    specify do
      expect(a_value == 3).to be_aliased_to(be == 3).with_description("a value == 3")
    end

    specify do
      expect(a_value === 3).to be_aliased_to(be === 3).with_description("a value === 3")
    end

    specify do
      expect(
        a_value_within(0.1).of(3)
      ).to be_aliased_to(
        be_within(0.1).of(3)
      ).with_description("a value within 0.1 of 3")
    end

    specify do
      expect(
        a_range_covering(1, 2)
      ).to be_aliased_to(
        cover(1, 2)
      ).with_description("a range covering 1 and 2")
    end

    specify do
      expect(
        a_collection_ending_with(23)
      ).to be_aliased_to(
        end_with(23)
      ).with_description("a collection ending with 23")
    end

    specify do
      expect(
        an_array_ending_with(23)
      ).to be_aliased_to(
        end_with(23)
      ).with_description("an array ending with 23")
    end

    specify do
      expect(
        a_string_ending_with("z")
      ).to be_aliased_to(
        end_with("z")
      ).with_description('a string ending with "z"')
    end

    specify do
      expect(
        a_value_including("a")
      ).to be_aliased_to(
        include("a")
      ).with_description('a value including "a"')
    end

    specify do
      expect(
        a_string_matching(/foo/)
      ).to be_aliased_to(
        match(/foo/)
      ).with_description('a string matching /foo/')
    end

    specify do
      expect(
        a_collection_starting_with(23)
      ).to be_aliased_to(
        start_with(23)
      ).with_description("a collection starting with 23")
    end

    specify do
      expect(
        an_array_starting_with(23)
      ).to be_aliased_to(
        start_with(23)
      ).with_description("an array starting with 23")
    end

    specify do
      expect(
        a_string_starting_with("z")
      ).to be_aliased_to(
        start_with("z")
      ).with_description('a string starting with "z"')
    end
  end
end
