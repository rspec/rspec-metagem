module RSpec
  module Matchers
    module BuiltIn
      # @api private
      # Provides the implementation for `exist`.
      # Not intended to be instantiated directly.
      class Exist < BaseMatcher
        def initialize(*expected)
          @expected = expected
        end

        # @api private
        # @return [Boolean]
        def matches?(actual)
          @actual = actual
          valid_test? && actual_exists?
        end

        def does_not_match?(actual)
          @actual = actual
          valid_test? && !actual_exists?
        end

        # @api private
        # @return [String]
        def failure_message
          "expected #{@actual.inspect} to exist#{validity_message}"
        end

        # @api private
        # @return [String]
        def failure_message_when_negated
          "expected #{@actual.inspect} not to exist#{validity_message}"
        end

      private

        def valid_test?
          uniq_truthy_values.size == 1
        end

        def actual_exists?
          existence_values.first
        end

        def uniq_truthy_values
          @uniq_truthy_values ||= existence_values.map { |v| !!v }.uniq
        end

        def existence_values
          @existence_values ||= predicates.map { |p| @actual.__send__(p, *@expected) }
        end

        def predicates
          @predicates ||= [:exist?, :exists?].select { |p| @actual.respond_to?(p) }
        end

        def validity_message
          case uniq_truthy_values.size
          when 0
            " but it does not respond to either `exist?` or `exists?`"
          when 2
            " but `exist?` and `exists?` returned different values:\n\n"\
            " exist?: #{existence_values.first}\n"\
            "exists?: #{existence_values.last}"
          end
        end
      end
    end
  end
end
