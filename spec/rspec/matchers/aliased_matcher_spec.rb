require 'spec_helper'

module RSpec
  module Matchers
    describe AliasedMatcher do
      RSpec::Matchers.define :my_base_matcher do
        def foo
          13
        end

        def description
          "my base matcher description"
        end
      end

      it 'can get a method object for delegated methods', :if => (RUBY_VERSION.to_f > 1.8) do
        matcher = my_base_matcher
        decorated = AliasedMatcher.new(matcher, Proc.new { })

        expect(decorated.method(:foo).call).to eq(13)
      end

      it 'can get a method object for `description`' do
        matcher = my_base_matcher
        decorated = AliasedMatcher.new(matcher, Proc.new { "overriden description" })

        expect(decorated.method(:description).call).to eq("overriden description")
      end

      RSpec::Matchers.alias_matcher :my_overriden_matcher, :my_base_matcher do |desc|
        desc + " (overriden)"
      end

      it 'overrides the description with the provided block' do
        matcher = my_overriden_matcher
        expect(matcher.description).to eq("my base matcher description (overriden)")
      end

      RSpec::Matchers.alias_matcher :my_blockless_override, :my_base_matcher

      it 'provides a default description override based on the old and new games' do
        matcher = my_blockless_override
        expect(matcher.description).to eq("my blockless override description")
      end
    end
  end
end

