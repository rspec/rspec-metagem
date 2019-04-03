module RSpec
  module Matchers
    module BuiltIn
      # @api private
      # Provides the implementation for `be_a_kind_of`.
      # Not intended to be instantiated directly.
      class BeAKindOf < BaseMatcher
      private

        def match(expected, actual)
          if actual_object_respond_to?(actual, :kind_of?)
            actual.kind_of?(expected)
          elsif actual_object_respond_to?(actual, :is_a?)
            actual.is_a?(expected)
          else
            raise ::ArgumentError, "The #{matcher_name} matcher requires that " \
                                   "the actual object responds to either #kind_of? or #is_a? methods "\
                                   "but it responds to neigher of two methods."
          end
        end

        def actual_object_respond_to?(actual, method)
          ::Kernel.instance_method(:respond_to?).bind(actual).call(method)
        end
      end
    end
  end
end
