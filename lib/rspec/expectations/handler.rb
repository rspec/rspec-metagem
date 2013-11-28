module RSpec
  module Expectations

    # @api private
    class ExpectationHandler
      def self.check_message(msg)
        unless msg.nil? || msg.respond_to?(:to_str) || msg.respond_to?(:call)
          ::Kernel.warn [
            "WARNING: ignoring the provided expectation message argument (",
            msg.inspect,
            ") since it is not a string or a proc."
          ].join
        end
      end

      # Returns an RSpec-3 compatible matcher, wrapping a legacy one
      # in an adapter if necessary.
      #
      # @api private
      def self.rspec_3_matcher_from(matcher)
        LegacyMacherAdapter::RSpec2.wrap(matcher) ||
        LegacyMacherAdapter::RSpec1.wrap(matcher) || matcher
      end
    end

    # @api private
    class PositiveExpectationHandler < ExpectationHandler
      def self.handle_matcher(actual, matcher, message=nil, &block)
        check_message(message)
        matcher = rspec_3_matcher_from(matcher)

        ::RSpec::Matchers.last_should = :should
        ::RSpec::Matchers.last_matcher = matcher
        return ::RSpec::Matchers::BuiltIn::PositiveOperatorMatcher.new(actual) if matcher.nil?

        match = matcher.matches?(actual, &block)
        return match if match

        message = message.call if message.respond_to?(:call)
        message ||= matcher.failure_message

        if matcher.respond_to?(:diffable?) && matcher.diffable?
          ::RSpec::Expectations.fail_with message, matcher.expected, matcher.actual
        else
          ::RSpec::Expectations.fail_with message
        end
      end
    end

    # @api private
    class NegativeExpectationHandler < ExpectationHandler
      def self.handle_matcher(actual, matcher, message=nil, &block)
        check_message(message)
        matcher = rspec_3_matcher_from(matcher)

        ::RSpec::Matchers.last_should = :should_not
        ::RSpec::Matchers.last_matcher = matcher
        return ::RSpec::Matchers::BuiltIn::NegativeOperatorMatcher.new(actual) if matcher.nil?

        match = matcher.respond_to?(:does_not_match?) ?
                !matcher.does_not_match?(actual, &block) :
                matcher.matches?(actual, &block)
        return match unless match

        message = message.call if message.respond_to?(:call)
        message ||= matcher.failure_message_when_negated

        if matcher.respond_to?(:diffable?) && matcher.diffable?
          ::RSpec::Expectations.fail_with message, matcher.expected, matcher.actual
        else
          ::RSpec::Expectations.fail_with message
        end
      end
    end

    # Wraps a matcher written against one of the legacy protocols in
    # order to present the current protocol.
    #
    # @api private
    class LegacyMacherAdapter < defined?(::BasicObject) ? ::BasicObject : ::Object
      attr_reader :matcher

      def initialize(matcher)
        @matcher = matcher

        ::RSpec.warn_deprecation(<<-EOS.gsub(/^\s+\|/, ''))
          |--------------------------------------------------------------------------
          |#{matcher.class.name || matcher.inspect} implements a legacy RSpec matcher
          |protocol. For the current protocol you should expose the failure messages
          |via the `failure_message` and `failure_message_when_negated` methods.
          |(Used from #{CallerFilter.first_non_rspec_line})
          |--------------------------------------------------------------------------
        EOS
      end

      def method_missing(name, *args, &block)
        @matcher.__send__(name, *args, &block)
      end

      def respond_to?(name, *args)
        super || @matcher.respond_to?(name, *args)
      end

      def self.wrap(matcher)
        new(matcher) if interface_matches?(matcher)
      end

      # Starting in RSpec 1.2 (and continuing through all 2.x releases),
      # the failure message protocol was:
      #   * `failure_message_for_should`
      #   * `failure_message_for_should_not`
      # @api private
      class RSpec2 < self
        def failure_message
          matcher.failure_message_for_should
        end

        def failure_message_when_negated
          matcher.failure_message_for_should_not
        end

        def self.interface_matches?(matcher)
          matcher.respond_to?(:failure_message_for_should) ||
          matcher.respond_to?(:failure_message_for_should_not)
        end
      end

      # Before RSpec 1.2, the failure message protocol was:
      #   * `failure_message`
      #   * `negative_failure_message`
      # @api private
      class RSpec1 < self
        def failure_message
          matcher.failure_message
        end

        def failure_message_when_negated
          matcher.negative_failure_message
        end

        # Note: `failure_message` is part of the RSpec 3 protocol
        # (paired with `failure_message_when_negated`), so we don't check
        # for `failure_message` here.
        def self.interface_matches?(matcher)
          matcher.respond_to?(:negative_failure_message)
        end
      end
    end
  end
end

