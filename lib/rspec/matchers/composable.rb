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

    private unless defined?(::YARD)

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
      # @public
      def values_match?(expected, actual)
        Support::FuzzyMatcher.values_match?(expected, actual)
      end

      # Returns the description of the given object in a way that is
      # aware of composed matchers. If the object is a matcher with
      # a `description` method, returns the description; otherwise
      # returns `object.inspect`.
      #
      # You are encouraged to use this in your custom matcher's
      # `description`, `failure_message` or
      # `failure_message_when_negated` implementation if you are
      # supporting matcher arguments.
      #
      # @api public
      def description_of(object)
        return object.description if Matchers.is_a_describable_matcher?(object)
        object.inspect
      end

      # Transforms the given data structue (typically a hash or array)
      # into a new data structure that, when `#inspect` is called on it,
      # will provide descriptions of any contained matchers rather than
      # the normal `#inspect` output.
      #
      # You are encouraged to use this in your custom matcher's
      # `description`, `failure_message` or
      # `failure_message_when_negated` implementation if you are
      # supporting any arguments which may be a data structure
      # containing matchers.
      #
      # @api public
      def surface_descriptions_in(item)
        if Matchers.is_a_describable_matcher?(item)
          DescribableItem.new(item)
        elsif Hash === item
          Hash[ surface_descriptions_in(item.to_a) ]
        elsif enumerable?(item)
          item.map { |subitem| surface_descriptions_in(subitem) }
        else
          item
        end
      end

      if String.ancestors.include?(Enumerable) # 1.8.7
        # Strings are not enumerable on 1.9, and on 1.8 they are an infinitely
        # nested enumerable: since ruby lacks a character class, it yields
        # 1-character strings, which are themselves enumerable, composed of a
        # a single 1-character string, which is an enumerable, etc.
        #
        # @api private
        def enumerable?(item)
          return false if String === item
          Enumerable === item
        end
      else
        # @api private
        def enumerable?(item)
          Enumerable === item
        end
      end
      module_function :surface_descriptions_in, :enumerable? unless defined?(::YARD)

      # Wraps an item in order to surface its `description` via `inspect`.
      # @api private
      DescribableItem = Struct.new(:item) do
        def inspect
          "(#{item.description})"
        end

        def pretty_print(pp)
          pp.text "(#{item.description})"
        end
      end
    end
  end
end
