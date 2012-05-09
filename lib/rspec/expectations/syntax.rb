module RSpec
  module Expectations
    module Syntax
      extend self

      def enable_should(syntax_host = ::Kernel)
        return if should_enabled?(syntax_host)

        syntax_host.module_eval do
          # Passes if +matcher+ returns true.  Available on every +Object+.
          # @example
          #   actual.should eq(expected)
          #   actual.should be > 4
          # @param [Matcher]
          #   matcher
          # @param [String] message optional message to display when the expectation fails
          # @return [Boolean] true if the expectation succeeds (else raises)
          # @see RSpec::Matchers
          def should(matcher=nil, message=nil, &block)
            RSpec::Expectations::PositiveExpectationHandler.handle_matcher(self, matcher, message, &block)
          end

          # Passes if +matcher+ returns false.  Available on every +Object+.
          # @example
          #   actual.should_not eq(expected)
          # @param [Matcher]
          #   matcher
          # @param [String] message optional message to display when the expectation fails
          # @return [Boolean] false if the negative expectation succeeds (else raises)
          # @see RSpec::Matchers
          def should_not(matcher=nil, message=nil, &block)
            RSpec::Expectations::NegativeExpectationHandler.handle_matcher(self, matcher, message, &block)
          end
        end
      end

      def disable_should(syntax_host = ::Kernel)
        return unless should_enabled?(syntax_host)

        syntax_host.module_eval do
          undef should
          undef should_not
        end
      end

      def enable_expect(syntax_host = ::RSpec::Matchers)
        return if expect_enabled?(syntax_host)

        syntax_host.module_eval do
          def expect(*target, &target_block)
            target << target_block if block_given?
            raise ArgumentError.new("You must pass an argument or a block to #expect but not both.") unless target.size == 1
            ::RSpec::Expectations::ExpectationTarget.new(target.first)
          end
        end
      end

      def disable_expect(syntax_host = ::RSpec::Matchers)
        return unless expect_enabled?(syntax_host)

        syntax_host.module_eval do
          undef expect
        end
      end

      def should_enabled?(syntax_host = ::Kernel)
        syntax_host.method_defined?(:should)
      end

      def expect_enabled?(syntax_host = ::RSpec::Matchers)
        syntax_host.method_defined?(:expect)
      end
    end
  end
end

