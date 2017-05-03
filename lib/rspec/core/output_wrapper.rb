module RSpec
  module Core
    # @private
    class OutputWrapper
      # @private
      attr_writer :output

      # @private
      def initialize(output)
        @output = output
      end

      # Redirect calls for IO interface methods
      IO.instance_methods(false).each do |method|
        define_method(method) do |*args, &block|
          @output.send(method, *args, &block)
        end
      end
    end
  end
end
