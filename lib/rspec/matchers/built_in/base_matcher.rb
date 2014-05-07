module RSpec
  module Matchers
    module BuiltIn
      # @api private
      #
      # Used _internally_ as a base class for matchers that ship with
      # rspec-expectations and rspec-rails.
      #
      # ### Warning:
      #
      # This class is for internal use, and subject to change without notice.  We
      # strongly recommend that you do not base your custom matchers on this
      # class. If/when this changes, we will announce it and remove this warning.
      class BaseMatcher
        include RSpec::Matchers::Pretty
        include RSpec::Matchers::Composable

        # @api private
        # Used to detect when no arg is passed to `initialize`.
        # `nil` cannot be used because it's a valid value to pass.
        UNDEFINED = Object.new.freeze

        # @private
        attr_reader :actual, :expected, :rescued_exception

        def initialize(expected=UNDEFINED)
          @expected = expected unless UNDEFINED.equal?(expected)
        end

        # @api private
        # Indicates if the match is successful. Delegates to `match`, which
        # should be defined on a subclass. Takes care of consistently
        # initializing the `actual` attribute.
        def matches?(actual)
          @actual = actual
          match(expected, actual)
        end

        # @api private
        # Used to wrap a block of code that will indicate failure by
        # raising one of the named exceptions.
        #
        # This is used by rspec-rails for some of its matchers that
        # wrap rails' assertions.
        def match_unless_raises(*exceptions)
          exceptions.unshift Exception if exceptions.empty?
          begin
            yield
            true
          rescue *exceptions => @rescued_exception
            false
          end
        end

        # @api private
        # Provides a good generic failure message. Based on `description`.
        # When subclassing, if you are not satisfied with this failure message
        # you often only need to override `description`.
        # @return [String]
        def failure_message
          assert_ivars :@actual
          "expected #{@actual.inspect} to #{description}"
        end

        # @api private
        # Provides a good generic negative failure message. Based on `description`.
        # When subclassing, if you are not satisfied with this failure message
        # you often only need to override `description`.
        # @return [String]
        def failure_message_when_negated
          assert_ivars :@actual
          "expected #{@actual.inspect} not to #{description}"
        end

        # @api private
        # Generates a "pretty" description using the logic in {Pretty}.
        # @return [String]
        def description
          return name_to_sentence unless defined?(@expected)
          "#{name_to_sentence}#{to_sentence @expected}"
        end

        # @api private
        # Matchers are not diffable by default. Override this to make your
        # subclass diffable.
        def diffable?
          false
        end

        # @api private
        # Most matchers are value matchers (i.e. meant to work with `expect(value)`)
        # rather than block matchers (i.e. meant to work with `expect { }`), so
        # this defaults to false. Block matchers must override this to return true.
        def supports_block_expectations?
          false
        end

      private

        def assert_ivars(*expected_ivars)
          return unless (expected_ivars - present_ivars).any?
          raise "#{self.class.name} needs to supply#{to_sentence expected_ivars}"
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
