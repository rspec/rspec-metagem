module RSpec
  module Core
    module Pending
      def pending(message = 'No reason given')
        running_example.metadata[:pending] = true
        running_example.metadata[:execution_result][:pending_message] = message
        if block_given?
          begin
            result = yield
            running_example.metadata[:pending] = false
          rescue Exception => e
          end
          raise RSpec::Core::PendingExampleFixedError.new if result
        end
        throw :pending_declared_in_example, message
      end
    end
  end
end
