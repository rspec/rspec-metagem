require 'drb/drb'

module RSpec
  module Core
    class Runner

      def self.installed_at_exit?
        @installed_at_exit ||= false
      end

      def self.autorun
        return if installed_at_exit? || running_in_drb?
        @installed_at_exit = true
        at_exit { run(ARGV, $stderr, $stdout) ? exit(0) : exit(1) }
      end

      def self.running_in_drb?
        (DRb.current_server rescue false) &&
        !!((DRb.current_server.uri) =~ /druby\:\/\/127.0.0.1\:/)
      end

      def self.run(args, err, out)
        if args.any? {|a| %w[--drb -X].include? a}
          run_over_drb(args, err, out) || run_in_process(args, err, out)
        else
          run_in_process(args, err, out)
        end
      end

      def self.run_over_drb(args, err, out)
        DRbCommandLine.new(args).run(err, out)
      end

      def self.run_in_process(args, err, out)
        CommandLine.new(args).run(err, out)
      end

    end

  end
end
