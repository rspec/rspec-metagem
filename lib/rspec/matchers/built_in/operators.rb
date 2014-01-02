require 'rspec/support'

module RSpec
  module Matchers
    module BuiltIn
      class OperatorMatcher
        class << self
          def registry
            @registry ||= {}
          end

          def register(klass, operator, matcher)
            registry[klass] ||= {}
            registry[klass][operator] = matcher
          end

          def unregister(klass, operator)
            registry[klass] && registry[klass].delete(operator)
          end

          def get(klass, operator)
            klass.ancestors.each { |ancestor|
              matcher = registry[ancestor] && registry[ancestor][operator]
              return matcher if matcher
            }

            nil
          end
        end

        register Enumerable, '=~', BuiltIn::ContainExactly

        def initialize(actual)
          @actual = actual
        end

        def self.use_custom_matcher_or_delegate(operator)
          define_method(operator) do |expected|
            if uses_generic_implementation_of?(operator) && matcher = OperatorMatcher.get(@actual.class, operator)
              @actual.__send__(::RSpec::Matchers.last_expectation_handler.should_method, matcher.new(expected))
            else
              eval_match(@actual, operator, expected)
            end
          end

          negative_operator = operator.sub(/^=/, '!')
          if negative_operator != operator && respond_to?(negative_operator)
            define_method(negative_operator) do |expected|
              opposite_should = ::RSpec::Matchers.last_expectation_handler.opposite_should_method
              raise "RSpec does not support `#{::RSpec::Matchers.last_expectation_handler.should_method} #{negative_operator} expected`.  " +
                "Use `#{opposite_should} #{operator} expected` instead."
            end
          end
        end

        ['==', '===', '=~', '>', '>=', '<', '<='].each do |operator|
          use_custom_matcher_or_delegate operator
        end

        def fail_with_message(message)
          RSpec::Expectations.fail_with(message, @expected, @actual)
        end

        def description
          "#{@operator} #{@expected.inspect}"
        end

      private

        def uses_generic_implementation_of?(op)
          Support.method_handle_for(@actual, op).owner == ::Kernel
        rescue NameError
          false
        end

        def eval_match(actual, operator, expected)
          ::RSpec::Matchers.last_matcher = self
          @operator, @expected = operator, expected
          __delegate_operator(actual, operator, expected)
        end
      end

      class PositiveOperatorMatcher < OperatorMatcher
        def __delegate_operator(actual, operator, expected)
          if actual.__send__(operator, expected)
            true
          elsif ['==','===', '=~'].include?(operator)
            fail_with_message("expected: #{expected.inspect}\n     got: #{actual.inspect} (using #{operator})")
          else
            fail_with_message("expected: #{operator} #{expected.inspect}\n     got: #{operator.gsub(/./, ' ')} #{actual.inspect}")
          end
        end
      end

      class NegativeOperatorMatcher < OperatorMatcher
        def __delegate_operator(actual, operator, expected)
          return false unless actual.__send__(operator, expected)
          return fail_with_message("expected not: #{operator} #{expected.inspect}\n         got: #{operator.gsub(/./, ' ')} #{actual.inspect}")
        end
      end
    end
  end
end
