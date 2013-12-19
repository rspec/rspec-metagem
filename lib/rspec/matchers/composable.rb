require 'rspec/support/fuzzy_matcher'

module RSpec
  module Matchers
    # Mixin designed to support the composable matcher features
    # of RSpec 3+. Mix it into your custom matcher classes to
    # allow them to be used in a composable fashion.
    #
    # @api public
    module Composable
      # Creates a compound `and` expectation. The matcher will
      # only pass if both sub-matchers pass.
      # This can be chained together to form an arbitrarily long
      # chain of matchers.
      #
      # @example
      #   expect(alphabet).to start_with("a").and end_with("z")
      #
      # @note The negative form (`expect(...).not_to matcher.and other`)
      #   is not supported at this time.
      def and(matcher)
        BuiltIn::Compound::And.new self, matcher
      end

      # Creates a compound `or` expectation. The matcher will
      # pass if either sub-matcher passes.
      # This can be chained together to form an arbitrarily long
      # chain of matchers.
      #
      # @example
      #   expect(stoplight.color).to eq("red").or eq("green").or eq("yellow")
      #
      # @note The negative form (`expect(...).not_to matcher.or other`)
      #   is not supported at this time.
      def or(matcher)
        BuiltIn::Compound::Or.new self, matcher
      end

      # Delegates to `#matches?`. Allows matchers to be used in composable
      # fashion and also supports using matchers in case statements.
      def ===(value)
        matches?(value)
      end

    private

      # This provides a generic way to fuzzy-match an expected value against
      # an actual value. It understands nested data structures (e.g. hashes
      # and arrays) and is able to match against a matcher being used as
      # the expected value or within the expected value at any level of
      # nesting.
      #
      # Within a custom matcher you are encouraged to use this whenever your
      # matcher needs to match two values, unless it needs more precise semantics.
      # For example, the `eq` matcher _does not_ use this as it is meant to
      # use `==` (and only `==`) for matching.
      #
      # @param expected [Object] what is expected
      # @param actual [Object] the actual value
      #
      # @api public
      def values_match?(expected, actual)
        Support::FuzzyMatcher.values_match?(expected, actual)
      end

      def description_of(object)
        return object.description if Matchers.is_a_describable_matcher?(object)
        object.inspect
      end

      def surface_descriptions_in(items)
        return Hash[ surface_descriptions_in(items.to_a) ] if items.is_a?(Hash)

        items.map do |item|
          if Matchers.is_a_describable_matcher?(item)
            DescribableItem.new(item)
          elsif enumerable?(item)
            surface_descriptions_in(item)
          else
            item
          end
        end
      end

      if String.ancestors.include?(Enumerable) # 1.8.7
        # Strings are not enumerable on 1.9, and on 1.8 they are an infinitely
        # nested enumerable: since ruby lacks a character class, it yields
        # 1-character strings, which are themselves enumerable, composed of a
        # a single 1-character string, which is an enumerable, etc.
        def enumerable?(item)
          return false if String === item
          Enumerable === item
        end
      else
        def enumerable?(item)
          Enumerable === item
        end
      end

      DescribableItem = Struct.new(:item) do
        def inspect
          "(#{item.description})"
        end
      end
    end
  end
end
