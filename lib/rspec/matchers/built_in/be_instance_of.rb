module RSpec
  module Matchers
    module BuiltIn
      # @api private
      # Provides the implementation for `be_an_instance_of`.
      # Not intended to be instantiated directly.
      class BeAnInstanceOf < BaseMatcher
        # @api private
        # @return [String]
        def description
          "be an instance of #{expected}"
        end

      private

        def match(expected, actual)
          if actual_object_respond_to?(actual, :instance_of?)
            actual.instance_of?(expected)
          else
            raise ::ArgumentError, "The #{matcher_name} matcher requires that " \
                                   "the actual object responds to #instance_of? method " \
                                   "but it does not respond to the method."
          end
        end

        def actual_object_respond_to?(actual, method)
          ::Kernel.instance_method(:respond_to?).bind(actual).call(method)
        end
      end
    end
  end
end
