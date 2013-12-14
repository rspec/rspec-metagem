require 'spec_helper'

module RSpec
  module Matchers
    describe AliasedMatcher do
      matcher :my_aliased_matcher do
        def foo
          13
        end

        def description
          "base description"
        end
      end

      it 'can get a method object for delegated methods', :if => (RUBY_VERSION.to_f > 1.8) do
        matcher = my_aliased_matcher
        decorated = AliasedMatcher.new(matcher, Proc.new { })

        expect(decorated.method(:foo).call).to eq(13)
      end

      it 'can get a method object for `description`' do
        matcher = my_aliased_matcher
        decorated = AliasedMatcher.new(matcher, Proc.new { "overriden description" })

        expect(decorated.method(:description).call).to eq("overriden description")
      end
    end
  end
end

