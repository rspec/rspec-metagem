require 'rspec/matchers/dsl'

module RSpec
  module Matchers
    module BuiltIn
      class BeTruthy < BaseMatcher
        def match(_, actual)
          !!actual
        end

        def failure_message
          "expected: truthy value\n     got: #{actual.inspect}"
        end

        def failure_message_when_negated
          "expected: falsey value\n     got: #{actual.inspect}"
        end
      end

      class BeFalsey < BaseMatcher
        def match(_, actual)
          !actual
        end

        def failure_message
          "expected: falsey value\n     got: #{actual.inspect}"
        end

        def failure_message_when_negated
          "expected: truthy value\n     got: #{actual.inspect}"
        end
      end

      class BeNil < BaseMatcher
        def match(_, actual)
          actual.nil?
        end

        def failure_message
          "expected: nil\n     got: #{actual.inspect}"
        end

        def failure_message_when_negated
          "expected: not nil\n     got: nil"
        end
      end

      module BeHelpers
        private

        def args_to_s
          @args.empty? ? "" : parenthesize(inspected_args.join(', '))
        end

        def parenthesize(string)
          "(#{string})"
        end

        def inspected_args
          @args.collect{|a| a.inspect}
        end

        def expected_to_sentence
          split_words(@expected)
        end

        def args_to_sentence
          to_sentence(@args)
        end
      end

      class Be < BaseMatcher
        include BeHelpers

        def initialize(*args, &block)
          @args = args
        end

        def match(_, actual)
          !!actual
        end

        def failure_message
          "expected #{@actual.inspect} to evaluate to true"
        end

        def failure_message_when_negated
          "expected #{@actual.inspect} to evaluate to false"
        end

        [:==, :<, :<=, :>=, :>, :===, :=~].each do |operator|
          define_method operator do |operand|
            BeComparedTo.new(operand, operator)
          end
        end
      end

      class BeComparedTo < BaseMatcher
        include BeHelpers

        def initialize(operand, operator)
          @expected, @operator = operand, operator
          @args = []
        end

        def matches?(actual)
          @actual = actual
          @actual.__send__ @operator, @expected
        end

        def failure_message
          "expected: #{@operator} #{@expected.inspect}\n     got: #{@operator.to_s.gsub(/./, ' ')} #{@actual.inspect}"
        end

        def failure_message_when_negated
          message = "`expect(#{@actual.inspect}).not_to be #{@operator} #{@expected.inspect}`"
          if [:<, :>, :<=, :>=].include?(@operator)
            message + " not only FAILED, it is a bit confusing."
          else
            message
          end
        end

        def description
          "be #{@operator} #{expected_to_sentence}#{args_to_sentence}"
        end
      end

      class BePredicate < BaseMatcher
        include BeHelpers

        def initialize(*args, &block)
          @expected = parse_expected(args.shift)
          @args = args
          @block = block
        end

        def matches?(actual)
          @actual = actual

          if is_private_on?( @actual )
            raise Expectations::ExpectationNotMetError.new("expectation set on private method `#{predicate}`")
          end

          begin
            return @result = actual.__send__(predicate, *@args, &@block)
          rescue NameError => predicate_missing_error
          end

          begin
            return @result = actual.__send__(present_tense_predicate, *@args, &@block)
          rescue NameError
            raise predicate_missing_error
          end
        end

        def failure_message
          "expected #{predicate}#{args_to_s} to return true, got #{@result.inspect}"
        end

        def failure_message_when_negated
          "expected #{predicate}#{args_to_s} to return false, got #{@result.inspect}"
        end

        def description
          "#{prefix_to_sentence}#{expected_to_sentence}#{args_to_sentence}"
        end

        private

        # support 1.8.7
        if methods.first.is_a? String
          def is_private_on? actual
            actual.private_methods.include? predicate.to_s
          end
        else
          def is_private_on? actual
            actual.private_methods.include? predicate
          end
        end

        def predicate
          "#{@expected}?".to_sym
        end

        def present_tense_predicate
          "#{@expected}s?".to_sym
        end

        def parse_expected(expected)
          @prefix, expected = prefix_and_expected(expected)
          expected
        end

        def prefix_and_expected(symbol)
          Matchers::BE_PREDICATE_REGEX.match(symbol.to_s).captures.compact
        end

        def prefix_to_sentence
          split_words(@prefix)
        end
      end
    end
  end
end
