module RSpec
  module Core
    class DeprecationIO

      def initialize
        @io = $stderr
        @count = 0
        @filename = 'STD_ERR'
      end

      def set_output(filename)
        @filename = filename
        @io = File.open(filename,'w')
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
