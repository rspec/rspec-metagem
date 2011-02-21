module RSpec
  module Core
    module Pending
      class PendingDeclaredInExample < StandardError; end

      DEFAULT_MESSAGE = 'No reason given'

      def pending(*args)
        return self.class.before(:each) { pending(*args) } unless example

        options = args.last.is_a?(Hash) ? args.pop : {}
        message = args.first || DEFAULT_MESSAGE

        if options[:unless] || (options.has_key?(:if) && !options[:if])
          return block_given? ? yield : nil
        end

        example.metadata[:pending] = true
        example.metadata[:execution_result][:pending_message] = message
        if block_given?
          begin
            result = yield
            example.metadata[:pending] = false
          rescue Exception
          end
          raise RSpec::Core::PendingExampleFixedError.new if result
        end
        raise PendingDeclaredInExample.new(message)
      end
    end
  end
end
