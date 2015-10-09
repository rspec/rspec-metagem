RSpec::Support.require_rspec_support "method_signature_verifier"

module RSpec
  module Matchers
    module BuiltIn
      # @api private
      # Provides the implementation for `respond_to`.
      # Not intended to be instantiated directly.
      class RespondTo < BaseMatcher
        def initialize(*names)
          @names = names
          @expected_arity = nil
          @expected_keywords = []
        end

        # @api public
        # Specifies the number of expected arguments.
        #
        # @example
        #   expect(obj).to respond_to(:message).with(3).arguments
        def with(n)
          @expected_arity = n
          self
        end

        def with_keywords(*keywords)
          @expected_keywords = keywords
          self
        end
        alias :and_keywords :with_keywords

        # @api public
        # No-op. Intended to be used as syntactic sugar when using `with`.
        #
        # @example
        #   expect(obj).to respond_to(:message).with(3).arguments
        def argument
          self
        end
        alias :arguments :argument

        # @private
        def matches?(actual)
          find_failing_method_names(actual, :reject).empty?
        end

        # @private
        def does_not_match?(actual)
          find_failing_method_names(actual, :select).empty?
        end

        # @api private
        # @return [String]
        def failure_message
          "expected #{actual_formatted} to respond to #{@failing_method_names.map { |name| description_of(name) }.join(', ')}#{with_arity}"
        end

        # @api private
        # @return [String]
        def failure_message_when_negated
          failure_message.sub(/to respond to/, 'not to respond to')
        end

        # @api private
        # @return [String]
        def description
          "respond to #{pp_names}#{with_arity}"
        end

      private

        def find_failing_method_names(actual, filter_method)
          @actual = actual
          @failing_method_names = @names.__send__(filter_method) do |name|
            @actual.respond_to?(name) && matches_arity?(actual, name)
          end
          @failing_method_names
        end

        def matches_arity?(actual, name)
          expectation = Support::MethodSignatureExpectation.new
          expectation.count    = @expected_arity
          expectation.keywords = @expected_keywords

          return true if expectation.empty?

          signature = Support::MethodSignature.new(Support.method_handle_for(actual, name))

          Support::StrictSignatureVerifier.new(signature, []).with_expectation(expectation).valid?
        end

        def with_arity
          str = ''
          str << " with #{with_arity_string}" if @expected_arity
          str << " #{str.length == 0 ? 'with' : 'and'} #{with_keywords_string}" if @expected_keywords && @expected_keywords.count > 0
          str
        end

        def with_arity_string
          "#{@expected_arity} argument#{@expected_arity == 1 ? '' : 's'}"
        end

        def with_keywords_string
          kw_str = case @expected_keywords.count
                   when 1
                     @expected_keywords.first.inspect
                   when 2
                     @expected_keywords.map(&:inspect).join(' and ')
                   else
                     "#{@expected_keywords[0...-1].map(&:inspect).join(' and ')}, and #{@expected_keywords.first.inspect}"
          end

          "keyword#{@expected_keywords.count == 1 ? '' : 's'} #{kw_str}"
        end

        def pp_names
          @names.length == 1 ? "##{@names.first}" : description_of(@names)
        end
      end
    end
  end
end
