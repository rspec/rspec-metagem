RSpec::Support.require_rspec_support 'differ'

module RSpec
  module Expectations
    class << self
      # @private
      def differ
        RSpec::Support::Differ.new(
          :object_preparer => lambda { |object| RSpec::Matchers::Composable.surface_descriptions_in(object) },
          :color => RSpec::Matchers.configuration.color?
        )
      end

      # Raises an RSpec::Expectations::ExpectationNotMetError with message.
      # @param [String] message
      # @param [Object] expected
      # @param [Object] actual
      #
      # Adds a diff to the failure message when `expected` and `actual` are
      # both present.
      def fail_with(message, expected=nil, actual=nil)
        unless message
          raise ArgumentError, "Failure message is nil. Does your matcher define the " \
                               "appropriate failure_message[_when_negated] method to return a string?"
        end

        diff = differ.diff(actual, expected)
        message = "#{message}\nDiff:#{diff}" unless diff.empty?

        raise RSpec::Expectations::ExpectationNotMetError, message
      end
    end
  end
end
