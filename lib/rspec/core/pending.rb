module RSpec
  module Core
    module Pending
      def pending(message = 'No reason given')
        example.metadata[:pending] = true
        example.metadata[:execution_result][:pending_message] = message
        if block_given?
          begin
            result = yield
            example.metadata[:pending] = false
          rescue Exception => e
          end
          raise RSpec::Core::PendingExampleFixedError.new if result
        end
        throw :pending_declared_in_example, message
      end
    end
  end
end
