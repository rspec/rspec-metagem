module Rspec
  module Expectations
    class << self
      attr_accessor :differ
      
      # raises a Rspec::Expectations::ExpectationNotMetError with message
      #
      # When a differ has been assigned and fail_with is passed
      # <code>expected</code> and <code>target</code>, passes them
      # to the differ to append a diff message to the failure message.
      def fail_with(message, expected=nil, target=nil) # :nodoc:
        if message.nil?
          raise ArgumentError, "Failure message is nil. Does your matcher define the " +
                               "appropriate failure_message_for_* method to return a string?"
        end
        unless (differ.nil? || expected.nil? || target.nil?)
          if expected.is_a?(String)
            message << "\nDiff:" << self.differ.diff_as_string(target.to_s, expected)
          elsif !target.is_a?(Proc)
            message << "\nDiff:" << self.differ.diff_as_object(target, expected)
          end
        end
        Kernel::raise(Rspec::Expectations::ExpectationNotMetError.new(message))
      end
    end
  end
end
