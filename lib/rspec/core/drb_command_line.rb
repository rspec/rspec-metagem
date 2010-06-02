module RSpec
  module Core
    class DRbCommandLine
      def initialize(argv)
        @options = RSpec::Core::ConfigurationOptions.new(argv)
      end

      def run(err, out)
        begin
          begin
            DRb.start_service("druby://localhost:0")
          rescue SocketError, Errno::EADDRNOTAVAIL
            DRb.start_service("druby://:0")
          end
          spec_server = DRbObject.new_with_uri("druby://127.0.0.1:#{@options.drb_port}")
          spec_server.run(@options.to_drb_argv, err, out)
          true
        rescue DRb::DRbConnError
          err.puts "No DRb server is running. Running in local process instead ..."
          false
        end
      end
    end
  end
end
