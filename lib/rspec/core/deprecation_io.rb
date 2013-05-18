module RSpec
  module Core
    class DeprecationIO

      def initialize
        @io = $stderr
        @count = 0
        @description = 'STD_ERR'
      end
      attr_reader :io, :description

      def set_output(io, description = io.inspect)
        @description = description
        @io = io
      end

      def puts(message)
        @count += 1
        @io.puts message
      end

      def deprecations
        @count
      end

    end
  end
end
