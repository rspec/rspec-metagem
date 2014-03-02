require 'drb/drb'
RSpec::Support.require_rspec_core "drb_options"

module RSpec
  module Core
    # The 'rspec' command line in DRB mode
    class DRbCommandLine
      def initialize(options)
        @options = options
      end

      # The DRB port
      #
      # @return [Fixnum] The port to use for DRB
      def drb_port
        @options.options[:drb_port] || ENV['RSPEC_DRB'] || 8989
      end

      # Configures and runs a suite
      #
      # @param [IO] err
      # @param [IO] out
      def run(err, out)
        begin
          DRb.start_service("druby://localhost:0")
        rescue SocketError, Errno::EADDRNOTAVAIL
          DRb.start_service("druby://:0")
        end
        spec_server = DRbObject.new_with_uri("druby://127.0.0.1:#{drb_port}")
        spec_server.run(@options.drb_argv, err, out)
      end
    end
  end
end
