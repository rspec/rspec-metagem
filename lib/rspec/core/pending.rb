module RSpec
  module Core
    module Pending
      class SkipDeclaredInExample < StandardError
        attr_reader :argument

        def initialize(argument)
          @argument = argument
        end
      end

      # If Test::Unit is loaed, we'll use its error as baseclass, so that Test::Unit
      # will report unmet RSpec expectations as failures rather than errors.
      begin
        class PendingExampleFixedError < Test::Unit::AssertionFailedError; end
      rescue
        class PendingExampleFixedError < StandardError; end
      end

      NO_REASON_GIVEN = 'No reason given'
      NOT_YET_IMPLEMENTED = 'Not yet implemented'

      # @overload pending()
      # @overload pending(message)
      # @overload pending(message, &block)
      #
      # Marks an example as pending. The rest of the example will still be
      # executed, and if it passes the example will fail to indicate that the
      # pending can be removed.
      #
      # @param [String] message optional message to add to the summary report.
      #
      # @example
      #
      #     describe "an example" do
      #       # reported as "Pending: no reason given"
      #       it "is pending with no message" do
      #         pending
      #         raise "broken" 
      #       end
      #
      #       # reported as "Pending: something else getting finished"
      #       it "is pending with a custom message" do
      #         pending("something else getting finished")
      #         raise "broken"
      #       end
      #     end
      #
      # @note `before(:each)` hooks are eval'd when you use the `pending`
      #   method within an example. If you want to declare an example `pending`
      #   and bypass the `before` hooks as well, you can pass `:pending => true`
      #   to the `it` method:
      #
      #       it "does something", :pending => true do
      #         # ...
      #       end
      #
      #   or pass `:pending => "something else getting finished"` to add a
      #   message to the summary report:
      #
      #       it "does something", :pending => "something else getting finished" do
      #         # ...
      #       end
      def pending(*args)
        current_example = RSpec.current_example

        if current_example
          Pending.mark_pending! current_example, args.first
        else
          raise "`pending` may not be used outside of examples, such as in " +
                "before(:all). Maybe you want `skip`?"
        end
      end

      # @overload skip()
      # @overload skip(message)
      # @overload skip(message, &block)
      #
      # Marks an example as pending and skips execution when called without a
      # block. When called with a block, skips just that block and does not
      # mark the example as pending. The block form is provided as replacement
      # for RSpec 2's pending-with-block feature, and is not recommended for
      # new code. Use simple conditionals instead.
      #
      # @param [String] message optional message to add to the summary report.
      # @block [Block] block optional block to be skipped
      #
      # @example
      #
      #     describe "an example" do
      #       # reported as "Pending: no reason given"
      #       it "is skipped with no message" do
      #         skip
      #       end
      #
      #       # reported as "Pending: something else getting finished"
      #       it "is skipped with a custom message" do
      #         skip "something else getting finished"
      #       end
      #
      #       # Passes
      #       it "contains a skipped statement" do
      #         skip do
      #           fail
      #         end
      #       end
      #     end
      def skip(*args)
        current_example = RSpec.current_example

        if current_example
          Pending.mark_skipped! current_example, args.first
        end

        raise SkipDeclaredInExample.new(args.first)
      end

      def self.mark_skipped!(example, message_or_bool)
        Pending.mark_pending! example, message_or_bool
        example.metadata[:skip] = true
      end

      def self.mark_pending!(example, message_or_bool)
        message = if !message_or_bool || !(String === message_or_bool)
          NO_REASON_GIVEN
        else
          message_or_bool
        end

        example.metadata[:pending] = true
        example.metadata[:execution_result][:pending_message] = message
        example.execution_result[:pending_fixed] = false
      end

      def self.mark_fixed!(example)
        example.metadata[:pending] = false
        example.metadata[:execution_result][:pending_fixed] = true
      end
    end
  end
end
