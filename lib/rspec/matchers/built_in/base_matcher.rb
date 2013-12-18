module RSpec
  module Matchers
    module BuiltIn
      # @api private
      #
      # Used _internally_ as a base class for matchers that ship with
      # rspec-expectations.
      #
      # ### Warning:
      #
      # This class is for internal use, and subject to change without notice.  We
      # strongly recommend that you do not base your custom matchers on this
      # class. If/when this changes, we will announce it and remove this warning.
      class BaseMatcher
        include RSpec::Matchers::Pretty
        include RSpec::Matchers::Composable

        UNDEFINED = Object.new.freeze

        attr_reader :actual, :expected, :rescued_exception

        def initialize(expected = UNDEFINED)
          @expected = expected unless UNDEFINED.equal?(expected)
        end

        def matches?(actual)
          @actual = actual
          match(expected, actual)
        end

        def match_unless_raises(*exceptions)
          exceptions.unshift Exception if exceptions.empty?
          begin
            yield
            true
          rescue *exceptions => @rescued_exception
            false
          end
        end

        def failure_message
          assert_ivars :@actual
          "expected #{@actual.inspect} to #{description}"
        end

        def failure_message_when_negated
          assert_ivars :@actual
          "expected #{@actual.inspect} not to #{description}"
        end

        def description
          return name_to_sentence unless defined?(@expected)
          "#{name_to_sentence}#{to_sentence @expected}"
        end

        def diffable?
          false
        end

      private

        def assert_ivars(*expected_ivars)
          if (expected_ivars - present_ivars).any?
            raise "#{self.class.name} needs to supply#{to_sentence expected_ivars}"
          end
        end

        if RUBY_VERSION.to_f < 1.9
          def present_ivars
            instance_variables.map { |v| v.to_sym }
          end
        else
          alias present_ivars instance_variables
        end
      end
    end
  end
end
