module RSpec
  module Matchers
    # Decorator that wraps a matcher and overrides `description`
    # using the provided block in order to support an alias
    # of a matcher. This is intended for use when composing
    # matchers, so that you can use an expression like
    # `include( a_value_within(0.1).of(3) )` rather than
    # `include( be_within(0.1).of(3) )`, and have the corresponding
    # description read naturally.
    #
    # @api private
    class AliasedMatcher < MatcherDelegator
      def initialize(base_matcher, description_block)
        @description_block = description_block
        super(base_matcher)
      end

      # Forward messages on to the wrapped matcher.
      # Since many matchers provide a fluent interface
      # (e.g. `a_value_within(0.1).of(3)`), we need to wrap
      # the returned value if it responds to `description`,
      # so that our override can be applied when it is eventually
      # used.
      def method_missing(*)
        return_val = super
        return return_val unless return_val.respond_to?(:description)
        AliasedMatcher.new(return_val, @description_block)
      end

      # Provides the description of the aliased matcher. Aliased matchers
      # are designed to behave identically to the original matcher except
      # for this method. The description is different to reflect the aliased
      # name.
      #
      # @api private
      def description
        @description_block.call(super)
      end
    end
  end
end
